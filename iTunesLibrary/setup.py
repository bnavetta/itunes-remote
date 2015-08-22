'''
Wrappers for the "iTunesLibrary" framework on MacOS X.

These wrappers don't include documentation, please check Apple's documention
for information on how to use this framework and PyObjC's documentation
for general tips and tricks regarding the translation between Python
and (Objective-)C frameworks
'''

from pyobjc_setup import setup

setup(
    name='iTunesLibrary',
    version="1.0",
    description = "Wrappers for the framework iTunesLibrary on Mac OS X",
    author = 'Ben Navetta',
    author_email = 'ben.navetta@gmail.com',
    url = 'https://bennavetta.com',
    long_description=__doc__,
    packages = [ "iTunesLibrary" ],
    setup_requires = [
        'pyobjc-core>=3.0.4',
    ],
    install_requires = [
        'pyobjc-core>=3.0.4',
        'pyobjc-framework-Cocoa>=3.0.4',
    ],
    min_os_level="10.9",
)
