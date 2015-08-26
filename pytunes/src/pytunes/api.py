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
            self.value = value
        elif isinstance(value, six.string_types):
            self.value = int(value, 16)
        else:
            raise TypeError("Expected string or integer")

    @property
    def hex(self):
        return '{:X}'.format(self.value)

    def __str__(self):
        return self.hex

    def __repr__(self):
        return "PersistentID[{}]".format(self.hex)
    
    def __eq__(self, other):
        if not isinstance(other, PersistentID):
            return NotImplemented
        else:
            return self.value == other.value

    def __hash__(self):
        return hash(self.value)
