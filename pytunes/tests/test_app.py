import sys
import time
import pytest

from pytunes import PersistentID
from pytunes.app import ITunesApp, ShuffleMode, RepeatMode, PlayerState

song_id = PersistentID('32EA0ABFE8147F9')
song_title = 'Sunday Bloody Sunday'
playlist_id = PersistentID('5F564F8336F6ECDA')
playlist_title = 'Cookies'

@pytest.yield_fixture
def app():
    app = ITunesApp()
    if app.running:
        app.quit()
    app.run()
    time.sleep(1)
    yield ITunesApp()
    app.quit()

def test_track_lookup(app):
    track = app._track(song_id)
    assert track.name() == song_title

def test_current_track(app):
    app.play(song_id)
    assert app.current_track == song_id

def test_shuffle(app):
    app.set_shuffle(True)
    app.set_shuffle_mode(ShuffleMode.albums)

def test_repeat(app):
    app.set_repeat_mode(RepeatMode.one)

def test_volume(app):
    app.volume = 42
    assert app.volume == 42

def test_player_position(app):
    app.play(song_id)
    app.player_position = 90
    assert app.player_position == 90

def test_state(app):
    app.stop()
    assert app.player_state == PlayerState.stopped
    app.play(song_id)
    time.sleep(1)
    assert app.player_state == PlayerState.playing
    app.pause()
    assert app.player_state == PlayerState.paused
    app.play_pause()
    assert app.player_state == PlayerState.playing
    app.play_pause()
    assert app.player_state == PlayerState.paused
