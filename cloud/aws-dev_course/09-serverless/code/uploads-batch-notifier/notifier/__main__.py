import json
import logging
import os
from typing import Any, Dict

from .notifier import Notifier
from .queue import Queue
from .utils import configure_logging


logger = logging.getLogger(__name__)
queue = None
notifier = None


def handler(event, context) -> Dict[str, Any]:
    configure_logging(level='INFO')
    logger.info('Start working with event: %s', json.dumps(event))

    global queue
    if queue is None:
        queue = Queue(name=os.environ['SQS_NAME'])

    global notifier;
    if notifier is None:
        notifier = Notifier(name=os.environ['SNS_ARN'])

    payload = drain_queue()
    return payload


def drain_queue() -> Dict[str, Any]:
    images = []
    overall_size = 0
    while True:
        try:
            event = queue.pop()
        except IndexError:
            break
        overall_size += event['size']
        images.append(event['url'])

    payload = {'images': images, 'overall_size': overall_size}
    if overall_size:
        payload['message'] = (
            f'Sending summary of {len(images)} events, '
            f'with overall size {overall_size}'
        )
        notifier.publish_message(json.dumps(payload, indent=4))

    else:
        payload['message'] = 'There are no uploaded images'

    logger.info(payload['message'])
    return payload
