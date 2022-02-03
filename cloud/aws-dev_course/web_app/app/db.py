
from datetime import datetime
import os
from typing import Any, Dict
from pathlib import Path

from flask_migrate import Migrate
from flask_sqlalchemy import SQLAlchemy
from sqlalchemy.ext.hybrid import hybrid_property

from . import app


db = SQLAlchemy(app)
migrate = Migrate(app, db)


class Image(db.Model):

    __tablename__ = 'images'

    id = db.Column(db.Integer, primary_key=True)
    path = db.Column(db.String(255), unique=True)
    size = db.Column(db.Integer)
    last_update = db.Column(db.DateTime, default=datetime.utcnow)

    def __init__(self, path: str, size: int):
        self.path = path
        self.size = size

    def __repr__(self):
        return f'<Image {self.path}>'

    @hybrid_property
    def extension(self):
        return Path(self.path).suffix[1:]

    def json(self) -> Dict[str, Any]:
        json_data = {}
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
