from setuptools import setup, find_packages
from codecs import open
from os import path
import sys

here = path.abspath(path.dirname(__file__))

with open(path.join(here, 'DESCRIPTION.rst'), encoding='utf-8') as f:
    long_description = f.read()

with open(path.join(here, 'src', 'py_tunes', 'version.py')) as f:
    code = compile(f.read(), 'version.py', 'exec')
    exec(code)

requirements = [
    'pyobjc-framework-ScriptingBridge ~= 3.0',
    'six ~= 1.9',
    'sqlalchemy ~= 1.0',
    'appdirs ~= 1.0'
]

if sys.version_info <= (3,):
    requirements.append('enum34')

setup(
    name='py-tunes',
    version=__version__,
    description='A Python API for the iTunes application and music library',
    long_description=long_description,
    author='Ben Navetta',
    author_email='ben.navetta@gmail.com',
    url='https://github.com/roguePanda/itunes-remote',
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
    packages=find_packages('src'),
    package_dir={'': 'src'},
    package_data={'py_tunes': ['itunes-indexer']},
    eager_resources=['py_tunes/itunes-indexer'],
    zip_safe=True,
    install_requires=requirements,
    tests_require=['pytest ~= 2.7']
)
