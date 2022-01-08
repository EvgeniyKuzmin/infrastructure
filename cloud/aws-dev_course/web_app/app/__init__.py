import socket
from typing import Any, Dict

import boto3
from flask import Flask, url_for, request, render_template


app = Flask(__name__)
ec2 = boto3.resource('ec2', region_name='eu-west-1')


INFO = {
    'name': 'Kuzmin Evgenii',
    'email': 'evgenii_kuzmin1@epam.com',
    'github_url': 'https://github.com/EvgeniyKuzmin/infrastructure/tree/main/cloud/aws-dev_course',
}


def get_ec2_instance_info() -> Dict[str, str]:
    ec2_resources = (
        (inst, ifc) for inst in ec2.instances.all() for ifc in inst.network_interfaces
        if ifc.private_dns_name == socket.gethostname()
    )
    for instance, iface in ec2_resources:
        return {
            'instance_id': instance.id,
            'availability_zone': iface.subnet.availability_zone,
            'public_dns': ','.join([
                a['Association']['PublicDnsName'] for a in iface.private_ip_addresses
            ]),
            'public_ip': ','.join([
                a['Association']['PublicIp'] for a in iface.private_ip_addresses
            ]),
        }
    return {}


@app.route('/')
def index():
    ec2_info = get_ec2_instance_info()
    return render_template(
        'index.html',
        css_style=url_for('static', filename='style.css'),
        ec2_info=ec2_info,
        **INFO,
    )


@app.route('/region')
def show_region():
    return os.environ.get('AWS_DEFAULT_REGION', 'mars')


@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        return 'POST login'
    else:
        return 'GET login'


@app.route('/user/<username>')
def profile(username):
    return f'{username}\'s profile'


with app.test_request_context():
    print(url_for('index'))
    print(url_for('login'))
    print(url_for('login', next='/'))
    print(url_for('profile', username='John Doe'))
    print(url_for('static', filename='style.css'))
