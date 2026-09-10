def _is_digit(unit: UInt16) -> Bool:
    return unit >= 48 and unit <= 57


def _hex_digit(unit: UInt16) -> Int:
    if unit >= 48 and unit <= 57:
        return Int(unit - 48)
    if unit >= 65 and unit <= 70:
        return Int(unit - 65) + 10
    if unit >= 97 and unit <= 102:
        return Int(unit - 97) + 10
    return -1


def _hex_unit(value: UInt32) -> UInt16:
    return UInt16(value + 48) if value < 10 else UInt16(value + 87)
