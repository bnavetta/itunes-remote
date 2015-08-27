from setuptools import setup, find_packages

setup(
    name = 'itunes-server',
    version = '0.1',
    packages = find_packages(),
    install_requires = [
        'Flask ~= 0.10',
        'pytunes ~= 0.1'
    ],
    entry_points={
        'console_scripts': [
            'itunes-server = itunes_server:run'
        ]
    }
)
