from functools import wraps

import bcrypt
from flask import request, Response

from itunes_server import app

# http://flask.pocoo.org/snippets/8/

# AUTH_USERS is a dict mapping usernames to password hashes

def check_auth(username, password):
    users = app.config['AUTH_USERS']
    if username in users:
        expected_hash = users[username]
        return bcrypt.hashpw(password.encode('utf-8'), expected_hash) == expected_hash
    else:
        return False

def authenticate():
    return Response('Could not verify your credentials', 401,
    {'WWW-Authenticate': 'Basic realm="Login Required"'})

@app.before_request
def require_auth():
    auth = request.authorization
    if not auth or not check_auth(auth.username, auth.password):
        return authenticate()
