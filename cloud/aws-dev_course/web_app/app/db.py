
from datetime import datetime
from pathlib import Path
from typing import Any, Dict

from flask_migrate import Migrate
from flask_sqlalchemy import SQLAlchemy
from sqlalchemy.ext.hybrid import hybrid_property

from . import app


db = SQLAlchemy(app)
migrate = Migrate(app, db)


class Image(db.Model):

    __tablename__ = 'images'

    id = db.Column(db.Integer, primary_key=True)
    bucket = db.Column(db.String(255))
    path = db.Column(db.String(255))
    url = db.Column(db.String(1020))
    etag = db.Column(db.String(32))
    size = db.Column(db.Integer)
    last_update = db.Column(db.DateTime, default=datetime.utcnow)

    def __init__(self, bucket: str, path: str, url: str, etag: str, size: int):
        self.bucket = bucket
        self.path = path
        self.url = url
        self.etag = etag
        self.size = size

    def __repr__(self):
        return f'<Image {self.path}>'

    @hybrid_property
    def extension(self) -> str:
        return Path(self.path).suffix[1:]

    @hybrid_property
    def name(self) -> str:
        return Path(self.path).name

    def json(self) -> Dict[str, Any]:
        json_data = {}
        json_data['name'] = self.name
        json_data['extension'] = self.extension
        json_data['url'] = self.url
        for column in self.__table__.columns:
            column_value = getattr(self, column.name)
            if isinstance(column_value, (str, int)):
                json_data[column.name] = column_value
            elif isinstance(column_value, datetime):
                json_data[column.name] = column_value.isoformat()

        return json_data

    def update(self, *args, **kwargs):
        column_names = [c.name for c in self.__table__.columns]

        for column_name, new_value in kwargs.items():
            if column_name not in column_names:
                raise ValueError(f'Column name "{column_name}" is not existed in DB')
            setattr(self, column_name, new_value)
