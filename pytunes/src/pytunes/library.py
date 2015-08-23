import datetime

from .api import PersistentID

class ITunesLibrary(object):
    # __slots__ = 

class Item(object):
    __slots__ = ['persistent_id', 'title', 'artist', 'composer', 'rating',
                 'album', 'genre', 'total_time', 'track_number', 'content_rating',
                 'play_count', 'last_played_date', 'release_date']
