from setuptools import setup, find_packages

setup(
    name = 'itunes-server',
    version = '0.1',
    packages = find_packages(),
    install_requires = [
        'Flask ~= 0.10',
        'Flask-RESTful ~= 0.3',
        'marshmallow ~= 2.0b5',
        'py-tunes ~= 1.0b2'
    ],
    entry_points={
        'console_scripts': [
            'itunes-server = itunes_server:run'
        ]
    }
)
