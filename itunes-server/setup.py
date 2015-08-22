from setuptools import setup, find_packages

setup(
    name = 'itunes-server',
    version = '0.1',
    packages = find_packages(),
    install_requires = [
        'hug ~= 1.2.0',
        'pyobjc-core ~= 3.0.4',
        'pyobjc-framework-ScriptingBridge ~= 3.0.4',
        'iTunesLibrary ~= 1.0'
    ],
)
