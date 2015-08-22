class PersistentID:
    __slots__ = ['value']

    def __init__(self, value):
        if isinstance(value, str):
            self.value = int(value, base=16)
        elif isinstance(value, int):
            assert value > 0, 'PersistentID values should be unsigned'
            self.value = value

    def __str__(self):
        return "PersistentID[{}]".format(hex(self.value))

    def __eq__(self, other):
        if not isinstance(other, PersistentID):
            return NotImplemented
        else:
            return self.value == other.value

    def __hash__(self):
        return hash(self.value)
