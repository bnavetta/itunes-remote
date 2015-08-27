from flask import Blueprint, jsonify, request, abort
from flask.views import MethodView
from pytunes import ITunesApp, PersistentID, PlayerState

from .errors import InvalidUsage
from .json import get_json

control = Blueprint('control', __name__)
app = ITunesApp()

class PlayerStateAPI(MethodView):
    def get(self):
        return jsonify(state=app.player_state)

    def put(self):
        json = get_json()
        if not 'state' in json:
            raise InvalidUsage('Must specify new state')
        state = json['state']
        if state == 'stopped':
            app.stop()
        elif state == 'paused':
            app.pause()
        elif state == 'playing':
            if not app.player_state == PlayerState.playing:
                app.play_pause()
        elif state == 'resuming':
            app.resume()
        elif state == 'fast_forwarding':
            app.fast_forward()
        elif state == 'rewinding':
            app.rewind()
        else:
            raise InvalidUsage('Cannot transition to state "{}" through this API', state)
        return self.get()

control.add_url_rule('/state', view_func=PlayerStateAPI.as_view('player_state'))

class VolumeAPI(MethodView):
    def get(self):
        return jsonify(volume=app.volume)

    def put(self):
        json = get_json()
        if not 'volume' in json:
            raise InvalidUsage('Must specify volume')
        volume = json['volume']
        if not isinstance(volume, int):
            raise InvalidUsage('Volume must be an integer')
        if volume < 0 or volume > 100:
            raise InvalidUsage('Volume must be between 0 and 100')
        app.volume = volume
        return self.get()

control.add_url_rule('/volume', view_func=VolumeAPI.as_view('volume'))
