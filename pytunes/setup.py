from setuptools import setup, find_packages
from codecs import open
from os import path

here = path.abspath(path.dirname(__file__))

with open(path.join(here, 'DESCRIPTION.rst'), encoding='utf-8') as f:
    long_description = f.read()

execfile(path.join(here, 'pytunes', 'version.py'))

setup(
    name='pytunes',
    version=__version__,
    description='A Python API for the iTunes application and music library',
    long_description=long_description,
    url='https://bennnavetta.com',
    author='Ben Navetta',
    author_email='ben.navetta@gmail.com',
    license='MIT',
    classifiers=[
        'Development Status :: 4 - Beta',
        'Intended Audience :: Developers',
        'Topic :: Multimedia :: Sound/Audio',
        'Topic :: Software Development :: Libraries',
        'License :: OSI Approved :: MIT License',
        'Operating System :: MacOS :: MacOS X',
        'Programming Language :: Python :: 2',
        'Programming Language :: Python :: 3',
        'Programming Language :: Objective C',
    ],
    keywords='itunes osx',
    packages=find_packages(exclude=['contrib', 'docs', 'tests*']),
    install_requires=[
        'iTunesLibrary ~= 1.0',
        'pyobjc-framework-ScriptingBridge ~= 3.0.4',
        'six ~= 1.9.0'
    ],

)
