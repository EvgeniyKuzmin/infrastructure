from contextlib import suppress
from mimetypes import guess_type
from pathlib import Path
from typing import Dict, List, Optional

import boto3
import botocore

from . import app
from .db import db, Image
from .queue import queue
from .utils import build_s3_object_url, calculate_etag


class S3FileStorage:
    """Wrapper around S3 public storage with metadata-DB.

    Conflicts resolution:
    Adding:
    - A filename exists in Storage -                  > KeyError
    - A file with the same content exists in Storage -> ValueError
    Extracting/Deleting:
    - A filename doesn't exists in Storage           -> KeyError
    """

    def __init__(self, bucket_name: str, prefix: str = '') -> None:
        self._bucket_name = bucket_name
        self._prefix = prefix

        self._bucket = boto3.resource('s3').Bucket(self._bucket_name)

    def add(self, name: str, path: Path) -> Dict[str, str]:
        with suppress(KeyError):
            file_info = self.get(name)
            raise KeyError(
                'The file with the same name '
                f'exists in the storage: {file_info}',
            )

        etag = calculate_etag(path)
        same_etag_img = Image.query.filter_by(etag=etag).first()
        if same_etag_img is not None:
            raise ValueError(
                'The file with the same etag '
                f'exists in the storage: {same_etag_img.json()}',
            )

        self._bucket.put_object(
            Body=path.read_bytes(),
            Key=f'{self._prefix}{name}',
            ContentType=guess_type(path)[0],
        )

        metadata = {
            'bucket': self._bucket_name,
            'path': f'{self._prefix}{name}',
            'url': build_s3_object_url(
                self._bucket_name,
                self._bucket.meta.client.meta.endpoint_url,
                f'{self._prefix}{name}',
            ),
            'etag': etag,
            'size': path.stat().st_size,
        }

        queue.put({**metadata, 'extension': path.suffix[1:]})

        img = Image(**metadata)
        db.session.add(img)
        db.session.commit()

        return img.json()

    def get(self, name: str) -> Dict[str, str]:
        img = Image.query.filter_by(path=f'{self._prefix}{name}').first()
        if img is None:
            existed_object = self._get_first_from_bucket(name)
            if existed_object is None:
                raise KeyError(f'The file "{name}" doesn\'t exist')

            img = Image(
                bucket=existed_object.bucket_name,
                path=existed_object.key,
                url=build_s3_object_url(
                    self._bucket_name,
                    self._bucket.meta.client.meta.endpoint_url,
                    f'{self._prefix}{name}',
                ),
                etag=existed_object.e_tag[1:-1],
                size=existed_object.content_length,
                last_update=existed_object.last_modified,
            )
            db.session.add(img)
            db.session.commit()

        return img.json()

    def get_all(self) -> List[Dict[str, str]]:
        return [img.json() for img in Image.query.all()]

    def delete(self, name: str) -> None:
        img = Image.query.filter_by(path=f'{self._prefix}{name}').first()
        if img is None:
            KeyError(f'The file "{name}" doesn\'t exist')

        self._bucket.Object(f'{self._prefix}{name}').delete()
        db.session.delete(img)
        db.session.commit()

    def update(self, name: str, path: Path) -> Dict[str, str]:
        raise NotImplementedError

    def _get_first_from_bucket(self, name: str) -> 'Optional[s3.Object]':  # noqa: F821
        obj = self._bucket.Object(f'{self._prefix}{name}')
        try:
            obj.load()
        except botocore.exceptions.ClientError as e:
            if e.response['Error']['Code'] != '404':
                raise
        else:
            return obj


storage = S3FileStorage(
    bucket_name=app.config['S3_BUCKET_NAME'],
    prefix=app.config['S3_STORAGE_PREFIX'],
)
