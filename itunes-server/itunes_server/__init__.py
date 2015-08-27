import sys

from flask import Flask, g, jsonify
from werkzeug.exceptions import default_exceptions
from werkzeug.exceptions import HTTPException

from .control import control
from .errors import InvalidUsage
from .json import JSONEncoder

DEBUG=True

app = Flask(__name__)
app.config.from_object(__name__)
app.config.from_envvar('ITUNES_SERVER_SETTNGS', silent=True)
app.register_blueprint(control, url_prefix='/control')
app.json_encoder = JSONEncoder

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

# http://flask.pocoo.org/docs/0.10/patterns/sqlite3/#sqlite3
def get_library():
    from pytunes import ITunesLibrary
    library = getattr(g, '_library', None)
    if library is None:
        library = g._library = ITunesLibrary()
    return library

@app.teardown_appcontext
def close_library(exception):
    library = getattr(g, '_library', None)
    if library is not None:
        library.close()

def run():
    app.run(host='0.0.0.0')
