import os
import socket
from typing import Dict

import boto3


ec2 = None


def get_ec2_instance_info() -> Dict[str, str]:
    global ec2
    if ec2 is None:
        ec2 = boto3.resource('ec2')

    ec2_resources = (
        (inst, ifc) for inst in ec2.instances.all() for ifc in inst.network_interfaces
        if ifc.private_dns_name == socket.gethostname()
    )
    for instance, iface in ec2_resources:
        return {
            'instance_id': instance.id,
            'availability_zone': iface.subnet.availability_zone,
            'public_dns': ','.join(
                a['Association']['PublicDnsName'] for a in iface.private_ip_addresses
            ),
            'public_ip': ','.join(
                a['Association']['PublicIp'] for a in iface.private_ip_addresses
            ),
        }
    return {}
