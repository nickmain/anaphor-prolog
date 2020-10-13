package unit;

import utest.Assert;

class TestCase extends utest.Test {
	function testSuccess() {
		Assert.isTrue(true);
	}

	function testSanity() {
		Assert.isTrue(anaphor.prolog.reader.Char.isAlpha("_"));
	}
}