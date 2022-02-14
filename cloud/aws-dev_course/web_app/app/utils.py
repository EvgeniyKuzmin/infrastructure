from hashlib import md5
from pathlib import Path
from urllib.parse import urlparse


def calculate_etag(file_path: Path) -> str:
    etag = md5()

    with open(file_path, 'rb') as file:
        while True:
            chunk = file.read(etag.block_size)
            if not chunk:
                break
            etag.update(chunk)

    return etag.hexdigest()


def build_s3_object_url(bucket: str, endpoint: str, path: str) -> str:
    url = urlparse(endpoint)._replace(path=path)
    return url._replace(netloc=f'{bucket}.{url.netloc}').geturl()
