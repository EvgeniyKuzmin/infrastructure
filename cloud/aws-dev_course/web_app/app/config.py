import os
from pathlib import Path
import secrets


class BaseConfig:

    UPLOAD_FOLDER = Path(__file__).parents[1] / 'uploads'
    MAX_CONTENT_LENGTH = 16_000_000
    ALLOWED_EXTENSIONS = {'png', 'jpg', 'jpeg', 'gif'}

    SQLALCHEMY_TRACK_MODIFICATIONS = False

    @property
    def SQLALCHEMY_DATABASE_URI(self):
        return 'postgresql://{usr}:{pwd}@{host}/{db}'.format(
            usr=self.DB_USER,
            pwd=self.DB_PASSWORD,
            host=self.DB_HOST,
            db=self.DB_NAME,
        )

    USER_NAME = 'Kuzmin Evgenii'
    USER_EMAIL = 'evgenii_kuzmin1@epam.com'
    USER_GITHUB_SOLUTION = 'https://github.com/EvgeniyKuzmin/infrastructure/tree/main/cloud/aws-dev_course'

    DB_HOST = os.environ['DB_HOST']
    DB_NAME = os.environ['DB_NAME']
    DB_USER = os.environ['DB_USER']
    DB_PASSWORD = os.environ['DB_PASSWORD']

    S3_BUCKET_NAME = os.environ['BUCKET_NAME']
    S3_STORAGE_PREFIX = os.environ['BUCKET_PREFIX']

    def __init__(self):
        os.makedirs(self.UPLOAD_FOLDER, exist_ok=True)


class DevelopmentConfig(BaseConfig):

    TESTING = True
    ENV = 'development'

    SECRET_KEY = secrets.token_hex()


class ProductionConfig(BaseConfig):

    SECRET_KEY = os.environ['SECRET_KEY']
