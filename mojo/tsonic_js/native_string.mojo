from .string import JsString, string_from_char_code, string_from_code_point


def native_string_at(value: String, index: Float64) -> Optional[String]:
    var selected = JsString(value).at(index)
    if not selected:
        return None
    return Optional[String](selected.value().to_native_lossy())


def native_string_char_at(value: String, index: Float64) -> String:
    return JsString(value).char_at(index).to_native_lossy()


def native_string_char_code_at(value: String, index: Float64) -> Float64:
    return JsString(value).char_code_at(index)


def native_string_code_point_at(value: String, index: Float64) -> Optional[Float64]:
    return JsString(value).code_point_at(index)


def native_string_concat(value: String, *others: String) -> String:
    var result = value
    for other in others:
        result += other
    return result^


def native_string_ends_with(
    value: String,
    search: String,
    end_position: Float64 = Float64(FloatLiteral.infinity),
) -> Bool:
    return JsString(value).ends_with(JsString(search), end_position)


def native_string_includes(
    value: String, search: String, position: Float64 = 0
) -> Bool:
    return JsString(value).includes(JsString(search), position)


def native_string_index_of(
    value: String, search: String, position: Float64 = 0
) -> Float64:
    return JsString(value).index_of(JsString(search), position)


def native_string_last_index_of(
    value: String,
    search: String,
    position: Float64 = Float64(FloatLiteral.infinity),
) -> Float64:
    return JsString(value).last_index_of(JsString(search), position)


def native_string_pad_end(
    value: String, target_length: Float64, fill: String = " "
) -> String:
    return JsString(value).pad_end(target_length, JsString(fill)).to_native_lossy()


def native_string_pad_start(
    value: String, target_length: Float64, fill: String = " "
) -> String:
    return JsString(value).pad_start(target_length, JsString(fill)).to_native_lossy()


def native_string_repeat(value: String, count: Float64) raises -> String:
    return JsString(value).repeat(count).to_native_lossy()


def native_string_slice(
    value: String,
    start: Float64 = 0,
    end: Float64 = Float64(FloatLiteral.infinity),
) -> String:
    return JsString(value).slice(start, end).to_native_lossy()


def native_string_starts_with(
    value: String, search: String, position: Float64 = 0
) -> Bool:
    return JsString(value).starts_with(JsString(search), position)


def native_string_substr(
    value: String,
    start: Float64,
    length: Float64 = Float64(FloatLiteral.infinity),
) -> String:
    return JsString(value).substr(start, length).to_native_lossy()


def native_string_substring(
    value: String,
    start: Float64,
    end: Float64 = Float64(FloatLiteral.infinity),
) -> String:
    return JsString(value).substring(start, end).to_native_lossy()


def native_string_to_lower_case(value: String) raises -> String:
    return JsString(value).to_lower_case().to_native_lossy()


def native_string_to_string(value: String) -> String:
    return value


def native_string_to_upper_case(value: String) raises -> String:
    return JsString(value).to_upper_case().to_native_lossy()


def native_string_to_well_formed(value: String) -> String:
    return value


def native_string_trim(value: String) -> String:
    return JsString(value).trim().to_native_lossy()


def native_string_trim_end(value: String) -> String:
    return JsString(value).trim_end().to_native_lossy()


def native_string_trim_left(value: String) -> String:
    return JsString(value).trim_left().to_native_lossy()


def native_string_trim_right(value: String) -> String:
    return JsString(value).trim_right().to_native_lossy()


def native_string_trim_start(value: String) -> String:
    return JsString(value).trim_start().to_native_lossy()


def native_string_value_of(value: String) -> String:
    return value


def native_string_is_well_formed(value: String) -> Bool:
    _ = value
    return True


def native_string_from_char_code(*codes: Float64) -> String:
    return string_from_char_code(*codes).to_native_lossy()


def native_string_from_code_point(*codes: Float64) raises -> String:
    return string_from_code_point(*codes).to_native_lossy()
