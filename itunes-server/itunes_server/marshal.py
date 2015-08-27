from functools import wraps

from flask_restful.utils import unpack
from marshmallow.fields import Field
from py_tunes import PersistentID

# Based on https://github.com/flask-restful/flask-restful/blob/master/flask_restful/__init__.py#L637
class marshal_with(object):
    '''A decorator that applies marshalling via marshmallow to API method return values.'''

    def __init__(self, schema, many=False):
        self.schema = schema
        self.many = many

    def __call__(self, f):
        @wraps(f)
        def wrapper(*args, **kwargs):
            resp = f(*args, **kwargs)
            if isinstance(resp, tuple):
                data, code, headers = unpack(resp)
                return self.schema.dump(data, many=self.many).data, code, headers
            else:
                return self.schema.dump(resp, many=self.many).data
        return wrapper

class PersistentID(Field):
    '''A PersistentID field.'''
    def __init__(self, *args, **kwargs):
        return super(PersistentID, self).__init__(*args, **kwargs)

    def _serialize(self, value, attr, obj):
        if value is None:
            return None
        return value.hex

    def _deserialize(self, value, attr, data):
        return PersistentID(value)
