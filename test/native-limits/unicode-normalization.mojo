from std.unicode_normalization import normalize


def main():
    _ = normalize("e\u{301}")
