from setuptools import setup, find_packages
from codecs import open
from os import path
import sys

here = path.abspath(path.dirname(__file__))

with open(path.join(here, 'DESCRIPTION.rst'), encoding='utf-8') as f:
    long_description = f.read()

with open(path.join(here, 'src', 'pytunes', 'version.py')) as f:
    code = compile(f.read(), 'version.py', 'exec')
    exec(code)

requirements = [
    'pyobjc-framework-ScriptingBridge ~= 3.0.4',
    'six ~= 1.9.0',
    'pandas ~= 0.16.2',
]

if sys.version_info <= (3,):
    requirements.append('enum34')

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
    packages=find_packages('src'),
    package_dir={'': 'src'},
    package_data={'pytunes': ['itunes-indexer']},
    eager_resources=['pytunes/itunes-indexer'],
    zip_safe=True,
    install_requires=requirements,
    tests_require=['pytest ~= 2.7.2']
)
