package unit;

import utest.Assert;

class TestCase3 extends utest.Test {
	function testSuccess() {
		Assert.isTrue(true);
	}

	function testFailure() {
		Assert.isTrue(false);
	}
}