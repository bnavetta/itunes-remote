from os import path
import pytest

from py_tunes import PersistentID
from py_tunes.library import indexer_path

def test_indexer_binary():
    assert path.isfile(indexer_path())
