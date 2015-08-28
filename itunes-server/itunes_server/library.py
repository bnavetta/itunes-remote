from flask import Blueprint
from flask.views import MethodView
from flask_restful import Api, Resource
from marshmallow import Schema, fields
from py_tunes import ITunesLibrary, Artist, Album, Song, Playlist, PersistentID

from .errors import InvalidUsage
from .itunes import get_library
from .marshal import marshal_with, PersistentID as PersistentIDField

mod = Blueprint('library', __name__)
api = Api(mod)

class ArtistSchema(Schema):
    name = fields.Str()
    albums = fields.Nested('AlbumSchema', many=True, exclude=('artist', 'tracks'))
    songs = fields.Nested('SongSchema', many=True, exclude=('artist', 'album'))

class AlbumSchema(Schema):
    title = fields.Str()
    rating = fields.Integer()
    disc_number = fields.Integer()
    disc_count = fields.Integer()
    compilation = fields.Boolean()
    artist = fields.Nested('ArtistSchema', exclude=('albums', 'songs'))
    tracks = fields.Nested('SongSchema', exclude=('album', 'artist'), many=True)

class SongSchema(Schema):
    persistent_id = PersistentIDField()
    title = fields.Str()
    artist = fields.Nested('ArtistSchema', exclude=('songs', 'albums'))
    album = fields.Nested('AlbumSchema', exclude=('tracks', 'artist'))
    total_time = fields.Integer()
    track_number = fields.Integer()
    play_count = fields.Integer()
    last_played_date = fields.Date()
    location = fields.Url()
    release_date = fields.Date()
    year = fields.Integer()

class PlaylistSchema(Schema):
    persistent_id = PersistentIDField()
    name = fields.Str()
    items = fields.Nested('SongSchema', many=True) # exclude=('artist', 'album')
    visible = fields.Boolean() # is this actually useful?

artist_schema = ArtistSchema()
album_schema = AlbumSchema()
song_schema = SongSchema()
playlist_schema = PlaylistSchema()

class ArtistListResource(Resource):
    @marshal_with(artist_schema, many=True)
    def get(self):
        return get_library().artists().all()

class ArtistResource(Resource):
    @marshal_with(artist_schema)
    def get(self, artist_name):
        return get_library().find_artist(artist_name)

api.add_resource(ArtistListResource, '/artist')
api.add_resource(ArtistResource, '/artist/<string:artist_name>', endpoint='artist_ep')

class AlbumListResource(Resource):
    @marshal_with(album_schema, many=True)
    def get(self):
        return get_library().albums().all()

class AlbumResource(Resource):
    @marshal_with(album_schema)
    def get(self, album_title):
        return get_library().find_album(album_title)

api.add_resource(AlbumListResource, '/album')
api.add_resource(AlbumResource, '/album/<string:album_title>', endpoint='album_ep')

class SongListResource(Resource):
    @marshal_with(song_schema, many=True)
    def get(self):
        return get_library().songs().all()

class SongResource(Resource):
    @marshal_with(song_schema)
    def get(self, persistent_id):
        return get_library().find_song(PersistentID(persistent_id))

api.add_resource(SongListResource, '/song')
api.add_resource(SongResource, '/song/<string:persistent_id>', endpoint='song_ep')

class PlaylistListResource(Resource): # say that 10 times fast
    @marshal_with(playlist_schema, many=True)
    def get(self):
        return get_library().playlists().all()

class PlaylistResource(Resource):
    @marshal_with(playlist_schema)
    def get(self, persistent_id):
        return get_library().find_playlist(PersistentID(persistent_id)) # TODO: URL variable converter for PersistentID

api.add_resource(PlaylistListResource, '/playlist')
api.add_resource(PlaylistResource, '/playlist/<string:persistent_id>', endpoint='playlist_ep')
