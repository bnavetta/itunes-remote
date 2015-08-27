from enum import Enum
from Foundation import NSPredicate
from ScriptingBridge import SBApplication

from .api import PersistentID

class ShuffleMode(Enum):
    songs = 1
    albums = 2
    groupings = 3

class RepeatMode(Enum):
    off = 1
    all = 2
    one = 3

class PlayerState(Enum):
    # from printing FourCC values
    stopped = 1800426323
    playing = 1800426320
    paused = 1800426352
    fast_forwarding = 1800426310
    rewinding = 1800426322

class ITunesApp(object):
    __slots__ = ['_itunes_app', '_system_events']

    def __init__(self):
        self._itunes_app = SBApplication.applicationWithBundleIdentifier_('com.apple.iTunes')
        self._system_events = SBApplication.applicationWithBundleIdentifier_('com.apple.systemevents')

    @property
    def running(self):
        '''Whether or not iTunes is open.'''
        return self._itunes_app.isRunning()

    def run(self):
        '''Run iTunes.'''
        self._itunes_app.run()

    def quit(self):
        '''Quit iTunes.'''
        self._itunes_app.quit()

    @property
    def current_track(self):
        '''The currently targeted track.'''
        current_track = self._itunes_app.currentTrack()
        if current_track is not None and current_track.persistentID() is not None:
            return PersistentID(current_track.persistentID())
        else:
            return None

    @property
    def current_playlist(self):
        playlist = self._itunes_app.currentPlaylist()
        if playlist is not None and playlist.persistentID() is not None:
            return PersistentID(playlist.persistentID())
        else:
            return None

    def next_track(self):
        self._itunes_app.nextTrack()

    def back_track(self):
        self._itunes_app.backTrack()

    def previous_track(self):
        self._itunes_app.previousTrack()

    # TODO: would it be possible to check this stuff via the menu?
    def set_shuffle(self, shuffle):
        '''
        Enable or disable shuffling.

        Args:
          shuffle (bool): Whether or not to shuffle items.
        '''
        item_name = 'On' if shuffle else 'Off'
        item = self._control_menu('Shuffle').menuItems().objectWithName_(item_name)
        item.clickAt_(item.position())

    def set_shuffle_mode(self, shuffle_mode):
        if shuffle_mode == ShuffleMode.songs:
            item_name = 'Songs'
        elif shuffle_mode == ShuffleMode.albums:
            item_name = 'Albums'
        elif shuffle_mode == ShuffleMode.groupings:
            item_name = 'Groupings'
        item = self._control_menu('Shuffle').menuItems().objectWithName_(item_name)
        item.clickAt_(item.position())

    def set_repeat_mode(self, repeat_mode):
        if repeat_mode == RepeatMode.off:
            item_name = 'Off'
        elif repeat_mode == RepeatMode.all:
            item_name = 'All'
        elif repeat_mode == RepeatMode.one:
            item_name = 'One'
        item = self._control_menu('Repeat').menuItems().objectWithName_(item_name)
        item.clickAt_(item.position())

    def volume():
        doc = "The sound output volume from 0 to 100."
        def fget(self):
            return self._itunes_app.soundVolume()
        def fset(self, value):
            self._itunes_app.setSoundVolume_(value)
        return locals()
    volume = property(**volume())

    def player_position():
        doc = "The position in seconds of the music player. Setting this property will seek within the current track."
        def fget(self):
            return self._itunes_app.playerPosition()
        def fset(self, value):
            self._itunes_app.setPlayerPosition_(value)
        return locals()
    player_position = property(**player_position())

    @property
    def player_state(self):
        return PlayerState(self._itunes_app.playerState())

    def play(self, persistent_id):
        item = self._track(persistent_id)
        if item is None or item.persistentID() is None:
            item = self._playlist(persistent_id)

        if item is not None and item.persistentID() is not None:
            item.playOnce_(True)
        else:
            pass # TODO: error

    def pause(self):
        self._itunes_app.pause()

    def resume(self):
        self._itunes_app.resume()

    def stop(self):
        self._itunes_app.stop()

    def play_pause(self):
        self._itunes_app.playpause()

    def fast_forward(self):
        self._itunes_app.fastForward()

    def rewind(self):
        self._itunes_app.rewind()

    @property
    def _library(self):
        return self._itunes_app.sources()[0]

    def _track(self, persistentID):
        predicate = NSPredicate.predicateWithFormat_argumentArray_('persistentID == %@', [persistentID.hex])
        return self._library.libraryPlaylists()[0].tracks().filteredArrayUsingPredicate_(predicate)[0]

    def _playlist(self, persistentID):
        predicate = NSPredicate.predicateWithFormat_argumentArray_('persistentID == %@', [persistentID.hex])
        return self._library.userPlaylists().filteredArrayUsingPredicate_(predicate)[0]

    @property
    def _process(self):
        predicate = NSPredicate.predicateWithFormat_argumentArray_('bundleIdentifier == %@', ['com.apple.iTunes'])
        return self._system_events.processes().filteredArrayUsingPredicate_(predicate)[0]

    def _control_menu(self, name):
        return self._process.menuBars()[0].menuBarItems().objectWithName_('Controls').menus()[0].menuItems().objectWithName_(name).menus()[0]
