import datetime
import pkg_resources

from .api import PersistentID

def indexer_path():
    return pkg_resources.resource_filename(__name__, 'itunes-indexer')

class ITunesLibrary(object):
    # __slots__ =
    pass

# use datetime.timedelta

class Item(object):
    __slots__ = ['persistent_id', 'title', 'artist', 'composer', 'rating',
                 'album', 'genre', 'total_time', 'track_number', 'content_rating',
                 'play_count', 'last_played_date', 'release_date']
