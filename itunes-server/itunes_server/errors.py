import sys

from flask import jsonify
from werkzeug.exceptions import default_exceptions
from werkzeug.exceptions import HTTPException

from itunes_server import app

# http://flask.pocoo.org/docs/0.10/patterns/apierrors/
class InvalidUsage(Exception):
    __slots__ = ['message', 'status_code', 'payload']
    def __init__(self, message, status_code=400, payload=None):
        Exception.__init__(self)
        self.message = message
        self.status_code = status_code
        self.payload = payload

    def to_dict(self):
        rv = dict(self.payload or ())
        rv['message'] = self.message
        return rv

# http://flask.pocoo.org/snippets/83/
def make_json_error(ex):
    app.log_exception(sys.exc_info())
    response = jsonify(message = str(ex))
    if isinstance(ex, HTTPException):
        response.status_code = ex.code
    else:
        response.status_code = 500
    return response

for code in default_exceptions.keys():
    app.error_handler_spec[None][code] = make_json_error

@app.errorhandler(InvalidUsage)
def handle_invalid_usage(error):
    response = jsonify(error.to_dict())
    response.status_code = error.status_code
    return response
