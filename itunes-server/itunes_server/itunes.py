from flask import g
from py_tunes import ITunesLibrary

from itunes_server import app

# http://flask.pocoo.org/docs/0.10/patterns/sqlite3/#sqlite3
def get_library():
    library = getattr(g, '_library', None)
    if library is None:
        library = g._library = ITunesLibrary()
    return library

@app.teardown_appcontext
def close_library(exception):
    library = getattr(g, '_library', None)
    if library is not None:
        library.close()
