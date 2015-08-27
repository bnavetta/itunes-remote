from enum import Enum

from flask import request
from flask.json import JSONEncoder as FlaskJSONEncoder
from pytunes import PersistentID

from .errors import InvalidUsage

class JSONEncoder(FlaskJSONEncoder):
    def default(self, o):
        if isinstance(o, PersistentID):
            return o.hex
        elif isinstance(o, Enum):
            return o.name
        else:
            return FlaskJSONEncoder.default(self, o)

def get_json():
    if request.content_type != 'application/json':
        raise InvalidUsage('Expected JSON request body')
    return request.get_json()
