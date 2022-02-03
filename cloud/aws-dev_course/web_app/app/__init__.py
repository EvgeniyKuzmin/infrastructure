import os
from pathlib import Path
import logging

from dotenv import load_dotenv
from flask import (
    Flask, flash, redirect, render_template, request, url_for,
    send_from_directory,
)
from healthcheck import HealthCheck
from werkzeug.utils import import_string, secure_filename


env = os.getenv('FLASK_ENV', 'production')
load_dotenv(Path(__file__).parents[1] / f'.env.{env}')
app = Flask(__name__)
app.config.from_object(
    import_string(f'{__name__}.config.{env.title()}Config')(),
)


from .ec2 import get_ec2_instance_info  # noqa
from .db import db, Image  # noqa


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

            new_img = Image(path=filename, size=filepath.stat().st_size)
            db.session.add(new_img)
            db.session.commit()

            return redirect(url_for('download_file', name=filename))

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


@app.route('/env/<key>', methods=('GET',))
def get_env(key):
    assert request.method == 'GET'
    return os.environ.get(key, 'null')


@app.route('/images', methods=('GET', 'POST'))
def images():
    if request.method == 'POST':
        if not request.is_json:
            return {'error': 'The request payload is not in JSON format'}

        new_img = Image(**request.get_json())
        db.session.add(new_img)
        db.session.commit()
        return {
            'message': f'car {new_img.path} has been created successfully.',
        }

    elif request.method == 'GET':
        results = [img.json() for img in Image.query.all()]
        return {'count': len(results), 'images': results}


@app.route('/image/<image_id>', methods=('GET', 'PUT', 'DELETE'))
def image(image_id):
    img = Image.query.get_or_404(image_id)

    if request.method == 'GET':
        return {'message': 'success', 'image': img.json()}

    elif request.method == 'PUT':
        if not request.is_json:
            return {'error': 'The request payload is not in JSON format'}

        img.update(**request.get_json())
        db.session.add(img)
        db.session.commit()
        return {'message': f'Image {img.path} successfully updated'}

    elif request.method == 'DELETE':
        db.session.delete(img)
        db.session.commit()
        return {'message': f'Image {img.path} successfully deleted.'}
