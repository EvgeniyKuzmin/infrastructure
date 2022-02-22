import logging
from typing import Optional


def configure_logging(
        format_: Optional[str] = None, level: Optional[str] = None,
        ) -> None:

    root = logging.getLogger()
    for handler in (root.handlers or ()):
        root.removeHandler(handler)
    kwargs = {}
    if format_ is not None:
        kwargs = {'format': format_}
    if level is not None:
        kwargs['level'] = level

    logging.basicConfig(**kwargs)
