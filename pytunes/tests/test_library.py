from os import path
import pytest

from pytunes import PersistentID
from pytunes.library import indexer_path

def test_indexer_binary():
    assert path.isfile(indexer_path())
