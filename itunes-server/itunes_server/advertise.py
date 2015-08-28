import logging

from Foundation import NSNetService, NSObject, NSNetServicesErrorCode

logger = logging.getLogger(__name__)

class BNNetServiceDelegate(NSObject):
    def netServiceDidPublish_(self, sender):
        logger.info('Registered service {}'.format(sender.name()))

    def netService_didNotPublish_(self, sender, errorDict):
        logger.error('Service registration failed: {}'.format(errorDict[NSNetServicesErrorCode]))

class NetworkAdvertiser(object):
    __slots__ = ['_net_service', '_delegate']

    def __init__(self, type, port, domain="", name=""):
        self._net_service = NSNetService.alloc().initWithDomain_type_name_port_(domain, type, name, port)
        self._delegate = BNNetServiceDelegate.alloc().init()
        self._net_service.setDelegate_(self._delegate)
        self._net_service.publish()

    def close(self):
        self._net_service.stop()
