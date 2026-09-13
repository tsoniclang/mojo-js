from std.testing import assert_equal, assert_true, assert_false
from tsonic_runtime import TypedLocation
from tsonic_js import JsArray, array_location


def escaped() raises -> TypedLocation[Int32]:
    var owner = JsArray[Int32]([4, 5])
    return array_location(owner, 1.0)


def main() raises:
    var owner = JsArray[Int32]([1, 2])
    var first = array_location(owner, 0.0)
    var same = array_location(owner, -0.0)
    var different = array_location(owner, 1.0)
    assert_true(first.same_storage(same))
    assert_equal(first.identity.hash(), same.identity.hash())
    assert_false(first.same_storage(different))
    for index in range(2048):
        _ = owner.push([Int32(index)])
    first.write(7)
    assert_equal(owner[0.0], 7)
    assert_equal(same.read(), 7)
    owner = JsArray[Int32]([20])
    first.write(8)
    assert_equal(owner[0.0], 20)
    assert_equal(same.read(), 8)
    var retained = escaped()
    retained.write(11)
    assert_equal(retained.read(), 11)
    var invalid_values: List[Float64] = [
        -1.0,
        0.5,
        4294967295.0,
        Float64("nan"),
    ]
    for invalid in invalid_values:
        var rejected = False
        try:
            _ = array_location(owner, invalid)
        except:
            rejected = True
        assert_true(rejected)
