import six

class PersistentID(object):
    """
    An iTunes persistent identifier that uniquely represents a track, playlist,
    or other entity.

    Attributes:
      value (int): The raw numerical identifier
      hex (str): The hexadecimal representation of this ID
    """
    __slots__ = ['value']

    def __init__(self, value):
        """Initializes PersistentID from a raw value.

        Args:
            value: the raw persistentID value, either as a number or as a hexadecimal string
        """
        if isinstance(value, six.integer_types):
            assert value > 0, 'PersistentID values are unsigned'
            self.value = value
        else:
            self.value = int(value, 16)

    @property
    def hex(self):
        return '{:X}'.format(self.value)

    def __str__(self):
        return "PersistentID[{}]".format(self.hex)

    def __eq__(self, other):
        if not isinstance(other, PersistentID):
            return NotImplemented
        else:
            return self.value == other.value

    def __hash__(self):
        return hash(self.value)
