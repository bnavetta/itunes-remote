from setuptools import setup, find_packages

setup(
    name = 'itunes-server',
    version = '0.1',
    packages = find_packages(),
    install_requires = [
        'hug ~= 1.2.0',
    ],
)
