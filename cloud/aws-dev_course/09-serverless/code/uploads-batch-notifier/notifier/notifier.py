import logging
from typing import Optional

import boto3


logger = logging.getLogger(__name__)


class Notifier:

    _resource = boto3.resource('sns')

    def __init__(self, name: str) -> None:
        self._topic = self._resource.Topic(name)

    def subscribe_email(self, address: str) -> None:
        sbs = self._topic.subscribe(
            Protocol='email', Endpoint=address, ReturnSubscriptionArn=True,
        )
        logger.info(
            'Subscribed "%s" (STATUS: %s) to the topic by id: %s',
            address,
            'confirmed' if sbs.attributes['PendingConfirmation'] == 'false' else 'pending',
            sbs.arn,
        )

    def unsubscribe_email(self, address: str) -> None:
        target_subscriptions = [
            s for s in self._topic.subscriptions.all()
            if s.arn not in ('PendingConfirmation', 'Deleted')
            and s.attributes['Protocol'] == 'email'
            and s.attributes['Endpoint'] == address
        ]
        if not target_subscriptions:
            raise KeyError(
                f'Didn\'t find an active subscription for "{address}"',
            )

        for subscription in target_subscriptions:
            subscription.delete()
            logger.info('Subscription for %s is deleted', address)

    def publish_message(
            self, message: str,
            subject: Optional[str] = None,
            ) -> None:

        attrs = {'Message': message}
        if subject is not None:
            attrs['Subject'] = subject
        self._topic.publish(**attrs)
