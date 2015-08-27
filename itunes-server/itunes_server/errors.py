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
