// Copyright © 2020, David N Main. All rights reserved.
// Licensed under the MIT License, see LICENSE file for details.

package unit;

class UnitTests {
    public static function main() {
        utest.UTest.run([
            new unit.ATestCase(), 
            new unit.LexerTests()
        ]);   
    }
}
