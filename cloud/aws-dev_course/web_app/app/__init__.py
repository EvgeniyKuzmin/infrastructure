import json
import logging
import os
from pathlib import Path
from urllib.request import urlopen

from dotenv import load_dotenv
from flask import (
    flash, Flask, redirect, render_template, request,
    send_from_directory, url_for,
)
from healthcheck import HealthCheck
from werkzeug.utils import import_string, secure_filename

load_dotenv(Path(__file__).parents[1] / '.env')
app = Flask(__name__)
app.config.from_object(
    import_string(f'{__name__}.config.ProductionConfig')(),  # TODO: where usecases for dev?
)


from .db import db  # noqa
from .ec2 import get_ec2_instance_info  # noqa
from .notifier import notifier  # noqa
from .storage import storage  # noqa
from .queue import queue  # noqa


def healthcheck_db():
    try:
        db.engine.execute("SELECT 1")
        return True, 'Database is OK'
    except Exception as e:
        return False, f'Database error: {e}'


health = HealthCheck()
health.add_check(healthcheck_db)
app.add_url_rule('/health', 'health', view_func=lambda: health.run())


@app.route('/')
def index():
    try:
        ec2_info = get_ec2_instance_info()
    except Exception as e:
        ec2_info = {'error': str(e)}

    return render_template(
        'index.html',
        css_style=url_for('static', filename='style.css'),
        ec2_info=ec2_info,
        **app.config.get_namespace('USER_'),
    )


@app.route('/env/<key>', methods=('GET',))
def get_env(key):
    assert request.method == 'GET'
    return os.environ.get(key, 'null')


@app.route('/uploads', methods=('GET', 'POST'))
def upload_file():
    if request.method == 'POST':
        if 'file' not in request.files:
            flash('No file part')
            return redirect(request.url)

        file = request.files['file']
        if not file.filename:
            flash('No selected file')
            return redirect(request.url)

        if file and Path(file.filename).suffix[1:] in \
                app.config['ALLOWED_EXTENSIONS']:
            filename = secure_filename(file.filename)
            filepath = app.config['UPLOAD_FOLDER'] / filename
            logging.warning('Saving the file by URL: %s', filepath)
            file.save(filepath)

            try:
                return storage.add(name=filepath.name, path=filepath)
            except (KeyError, ValueError) as e:
                return {'error': str(e)}

    return """
    <!doctype html>
    <title>Upload new File</title>
    <h1>Upload new File</h1>
    <form method=post enctype=multipart/form-data>
      <input type=file name=file>
      <input type=submit value=Upload>
    </form>
    """


@app.route('/uploads/<name>', methods=('GET',))
def download_file(name):
    logging.warning('Loading the file by URL: %s', name)
    return send_from_directory(app.config['UPLOAD_FOLDER'], name)


# TODO: added POST-method
@app.route('/images', methods=('GET',))
def images():
    if request.method == 'GET':
        images_ = storage.get_all()
        # breakpoint()
        return {'images': images_}
    # elif request.method == 'POST':
    #     if not request.is_json:
    #         return {'error': 'The request payload is not in JSON format'}

    #     new_img = Image(**request.get_json())
    #     db.session.add(new_img)
    #     db.session.commit()
    #     return {
    #         'message': f'car {new_img.path} has been created successfully.',
    #     }


# TODO: added PUT-method
@app.route('/image/<name>', methods=('GET', 'DELETE'))
def image(name):
    if request.method in ('GET', 'HEAD'):
        try:
            return {'image': storage.get(name)}
        except KeyError as e:
            return {'error': str(e)}, 404

    # elif request.method == 'PUT':
    #     if not request.is_json:
    #         return {'error': 'The request payload is not in JSON format'}

    #     img.update(**request.get_json())
    #     db.session.add(img)
    #     db.session.commit()
    #     return {'message': f'Image {img.path} successfully updated'}

    elif request.method == 'DELETE':
        try:
            storage.delete(name)
        except KeyError as e:
            return {'error': str(e)}

        return {'message': f'Image {name} successfully deleted.'}


@app.route('/subscribe', methods=('POST', 'DELETE'))
def subscribe():
    if not request.is_json:
        return {'error': 'The request payload is not in JSON format'}

    field_name = 'address'
    try:
        address = request.get_json()[field_name]
    except KeyError:
        return {'error': f'The request payload must contain "{field_name}"'}

    if request.method == 'POST':
        notifier.subscribe_email(address)
        return {
            'message': f'Email address {address} was successfully subscribed',
        }
    elif request.method == 'DELETE':
        try:
            notifier.unsubscribe_email(address)
        except KeyError as e:
            return {'error': str(e)}, 404

        return {
            'message': f'Email address {address} was successfully unsubscribed',
        }
    else:
        raise Exception(f'AAAaaa wrong method!!! {request.method}')


@app.route('/drain-queue')
def drain_queue():
    images = []
    overall_size = 0
    while True:
        try:
            event = queue.pop()
        except IndexError:
            break
        overall_size += event['size']
        images.append(event['url'])

    message = (
        f'Sending summary of {len(images)} events, '
        f'with overall size {overall_size}',
    )
    logging.info(message)
    notifier.publish_message(json.dumps({
        'overall_size': overall_size,
        'images': images,
    }))
    return {'message': message}


@app.route('/drain-queue-external')
def drain_queue_external():
    with urlopen(app.config['API_DRAIN_URL']) as resp:
        return json.loads(resp.read().decode())
