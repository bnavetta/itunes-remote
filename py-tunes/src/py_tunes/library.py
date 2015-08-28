import os
from os import path
import pkg_resources
import subprocess

import appdirs
from sqlalchemy import create_engine, Table, Column, ForeignKey, Integer, String, Boolean, Date
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker, relationship, backref

from py_tunes.api import PersistentID

index_path = path.join(appdirs.user_cache_dir(appname='py_tunes'), 'itunes.sqlite3')

_engine = create_engine('sqlite:///' + index_path)
Session = sessionmaker(bind=_engine)

Base = declarative_base()

class Artist(Base):
    __tablename__ = 'artist'

    name = Column(String, primary_key=True)

    def __repr__(self):
        return '<Artist(name="{0.name}")>'.format(self)

class Album(Base):
    __tablename__ = 'album'

    title = Column(String, primary_key=True)
    rating = Column(Integer)
    disc_number = Column(Integer)
    disc_count = Column(Integer)
    compilation = Column(Boolean)
    _album_artist = Column('album_artist', String, ForeignKey('artist.name'))

    def __repr__(self):
        return '<Album title="{0.title}" rating={0.rating} disc_number={0.disc_number} disc_count={0.disc_count} compilation={0.compilation} artist="{0._album_artist}">'.format(self)

_playlist_items = Table('playlist_items', Base.metadata,
    Column('playlist_id', String, ForeignKey('playlist.persistent_id')),
    Column('item_id', String, ForeignKey('song.persistent_id')))

class Song(Base):
    __tablename__ = 'song'

    _persistent_id = Column('persistent_id', String, primary_key=True)
    title = Column(String)
    _artist = Column('artist', String, ForeignKey('artist.name'))
    _album = Column('album', String, ForeignKey('album.title'))
    total_time = Column(Integer)
    track_number = Column(Integer)
    play_count = Column(Integer)
    last_played_date = Column(Date)
    location = Column(String)
    release_date = Column(Date)
    year = Column(Integer)

    def __repr__(self):
        return '<Song persistent_id={0.persistent_id} title="{0.title}" artist="{0._artist}" total_time={0.total_time} track_number={0.track_number} play_count={0.play_count} last_played_date={0.last_played_date} location={0.location} release_date={0.release_date} year={0.year}>'.format(self)

    @property
    def persistent_id(self):
        return PersistentID(self._persistent_id)

class Playlist(Base):
    __tablename__ = 'playlist'

    _persistent_id = Column('persistent_id', String, primary_key=True)
    name = Column(String)
    visible = Column(Boolean)

    @property
    def persistent_id(self):
        return PersistentID(self._persistent_id)

    def __repr__(self):
        return '<Playlist persistent_id={0.persistent_id} name="{0.name}" visible={0.visible}>'.format(self)

Artist.albums = relationship('Album', backref='artist')
Artist.songs = relationship('Song', backref='artist')
Album.tracks = relationship('Song', backref='album')
Playlist.items = relationship('Song', secondary=_playlist_items)

class ITunesLibrary(object):
    __slots__ = ['_session']

    def __init__(self):
        self._session = Session()

    def close(self):
        self._session.close()

    def find_artist(self, artist_name):
        return self._session.query(Artist).filter(Artist.name == artist_name).one()

    def artists(self):
        return self._session.query(Artist)

    def find_album(self, album_title):
        return self._session.query(Album).filter(Album.title == album_title).one()

    def albums(self):
        return self._session.query(Album)

    def find_song(self, persistent_id):
        if isinstance(persistent_id, PersistentID):
            persistent_id = persistent_id.hex
        return self._session.query(Song).filter(Song._persistent_id == persistent_id).one()

    def songs(self):
        return self._session.query(Song)

    def find_playlist(self, persistent_id):
        if isinstance(persistent_id, PersistentID):
            persistent_id = persistent_id.hex
        return self._session.query(Playlist).filter(Playlist._persistent_id == persistent_id).one()

    def playlists(self):
        return self._session.query(Playlist)
