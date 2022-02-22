from collections import deque
import json
import logging
from typing import Any

import boto3


class Queue:

    _resource = boto3.resource('sqs')
    _json = 'jsonified'

    def __init__(self, name: str) -> None:
        self._queue = self._resource.get_queue_by_name(QueueName=name)
        self._last_messages = deque()

    def put(self, item: Any) -> None:
        attributes = {self._json: {'DataType': 'String', 'StringValue': 'no'}}
        if not isinstance(item, str):
            attributes[self._json]['StringValue'] = 'yes'

        r = self._queue.send_message(
            MessageBody=item if isinstance(item, str) else json.dumps(item),
            MessageAttributes=attributes,
        )
        logging.info(
            '%s put the message into queue by id "%s": %s',
            'Successfully' if r['ResponseMetadata']['HTTPStatusCode'] else 'Unsuccessfully',
            r['MessageId'], item,
        )

    def get(self, count: int = 1) -> Any:
        items = []
        for message in self._queue.receive_messages(
                MessageAttributeNames=(self._json,),
                MaxNumberOfMessages=count,
                ):
            self._last_messages.append(message)
            if message.message_attributes[self._json]['StringValue'] == 'yes':
                items.append(json.loads(message.body))
            else:
                items.append(message.body)

        if not items:
            raise IndexError('The queue is empty')

        return items[0] if len(items) == 1 else items

    def delete_last(self, count: int = 1) -> None:
        while count:
            message = self._last_messages.pop()
            message.delete()
            logging.info('Message with id "%s" is deleted', message.message_id)
            count -= 1

    def pop(self) -> Any:
        item = self.get()
        self.delete_last()
        return item
