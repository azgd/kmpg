import unittest
from get_in import *

class TestGetIn(unittest.TestCase):

    def test_get_in_cannot_find_me(self):
        self.assertEqual(get_in({"a":{"c":"short"}}, "a/b"), None, "Should be None")

    def test_get_in_test_case_1(self):
        self.assertEqual(get_in({"a":{"b":{"c":"d"}}}, "a/b/c"), "d", "Should be d")

    def test_get_in_test_case_2(self):
        self.assertEqual(get_in({"x":{"y":{"z":"a"}}}, "x/y/z"), "a", "Should be a")

    def test_get_in_go_long(self):
        self.assertEqual(get_in({"a":{"b":{"c":{"d":{"e":"long"}}}}}, "a/b/c/d/e"), "long", "Should be long")

    def test_get_in_go_short(self):
        self.assertEqual(get_in({"a":{"b":"short"}}, "a/b"), "short", "Should be short")

    def test_get_in_go_really_short(self):
        self.assertEqual(get_in({"a":"short"}, "a"), "short", "Should be short")

    def test_get_in_cannot_find_me(self):
        self.assertEqual(get_in({"a":{"c":"short"}}, "a/b"), None, "Should be None")

    def test_get_in_what_do_you_expect(self):
        self.assertEqual(get_in({"a":{"c":"short"}}, ""), {"a":{"c":"short"}}, "Should Return the whole dictionary")

if __name__ == '__main__':
    unittest.main()