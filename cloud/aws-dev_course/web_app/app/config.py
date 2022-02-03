import os
import secrets
from pathlib import Path

from dotenv import load_dotenv
import yaml

_BASE_DIR = Path(__file__).parents[1]
load_dotenv(_BASE_DIR / f'{os.getenv("APP_MODE", "prod")}.env')


class BaseConfig:

    UPLOAD_FOLDER = _BASE_DIR / './uploads'
    MAX_CONTENT_LENGTH = 16_000_000
    ALLOWED_EXTENSIONS = {'txt', 'pdf', 'png', 'jpg', 'jpeg', 'gif'}

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

    def __init__(self):
        os.makedirs(self.UPLOAD_FOLDER, exist_ok=True)


class DevelopmentConfig(BaseConfig):

    TESTING = True
    ENV = 'development'

    DB_HOST = os.getenv('DB_HOST', 'localhost')
    DB_NAME = os.getenv('DB_NAME', 'images')
    DB_USER = os.getenv('DB_USER', 'evgenii')
    DB_PASSWORD = os.getenv('DB_PASSWORD', 'StR0nGPWD')

    SECRET_KEY = secrets.token_hex()


class ProductionConfig(BaseConfig):

    DB_HOST = os.getenv('DB_HOST')
    DB_NAME = os.getenv('DB_NAME')
    DB_USER = os.getenv('DB_USER')
    DB_PASSWORD = os.getenv('DB_PASSWORD')

    SECRET_KEY = os.getenv('SECRET_KEY')
