from numbers import Rational

from flask import Blueprint, jsonify, request, abort
from flask.views import MethodView
from pytunes import ITunesApp, PersistentID, PlayerState, ShuffleMode, RepeatMode

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

# TODO: expose full info (or at least more) from library for get operation

class CurrentTrackAPI(MethodView):
    def get(self):
        return jsonify(persistent_id=app.current_track)

    def put(self):
        json = get_json()
        if 'persistent_id' in json:
            persistent_id = PersistentID(json['persistent_id'])
            app.play(persistent_id)
        elif 'move' in json:
            movement = json['move']
            if movement == 'next':
                app.next_track()
            elif movement == 'back':
                app.back_track()
            elif movement == 'previous':
                app.previous_track()
            else:
                raise InvalidUsage('Unknown movement: {}'.format(movement))
        else:
            raise InvalidUsage('Must specify movement or persistent ID of track to play')
        return self.get()

control.add_url_rule('/current-track', view_func=CurrentTrackAPI.as_view('current_track'))

class CurrentPlaylistAPI(MethodView):
    def get(self):
        return jsonify(persistent_id=app.current_playlist)

    def put(self):
        json = get_json()
        if not 'persistent_id' in json:
            raise InvalidUsage('Must specify persistent ID of track to play')
        persistent_id = PersistentID(json['persistent_id'])
        app.play(persistent_id)
        return self.get()

control.add_url_rule('/current-playlist', view_func=CurrentPlaylistAPI.as_view('current_playlist'))

class ShuffleAPI(MethodView):
    def put(self):
        json = get_json()
        if 'enabled' in json:
            enabled = json['enabled']
            if not isinstance(enabled, bool):
                raise InvalidUsage('Expected boolean for "enabled", got {}'.format(enabled))
            app.set_shuffle(enabled)
        if 'mode' in json:
            mode = ShuffleMode[json['mode']]
            app.set_shuffle_mode(mode)
        return ('', 204)

control.add_url_rule('/shuffle', view_func=ShuffleAPI.as_view('shuffle'))

class RepeatAPI(MethodView):
    def put(self):
        json = get_json()
        if not 'mode' in json:
            raise InvalidUsage('Missing repeat mode')
        mode = RepeatMode[json['mode']]
        app.set_repeat_mode(mode)
        return ('', 204)

control.add_url_rule('/repeat', view_func=RepeatAPI.as_view('repeat'))

class PositionAPI(MethodView):
    def get(self):
        return jsonify(position=app.player_position)

    def put(self):
        json = get_json()
        if not 'position' in json:
            raise InvalidUsage('Missing "position" key')
        position = json['position']
        if not isinstance(position, Rational):
            raise InvalidUsage('Expected number for "position", got {}'.format(position))
        app.player_position = position
        return self.get()

control.add_url_rule('/position', view_func=PositionAPI.as_view('position'))
