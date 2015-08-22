from ScriptingBridge import SBApplication

from .persistent_id import PersistentID

class iTunesController:
    __slots__ = ['_itunes_app', '_system_events']

    def __init__(self):
        self._itunes_app = SBApplication.applicationWithBundleIdentifier_('com.apple.iTunes')
        self._system_events = SBApplication.applicationWithBundleIdentifier_('com.apple.systemevents')

    @property
    def running(self):
        # return self._itunes_app.running_()
        return self._itunes_app.running()
