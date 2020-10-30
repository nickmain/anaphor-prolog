// Copyright © 2020, David N Main. All rights reserved.
// Licensed under the MIT License, see LICENSE file for details.

package anaphor.prolog.reader;

import haxe.ds.StringMap;

typedef CharConverter = (String) -> String;

class CharConversionTable {
    public final mapping = new StringMap<String>();

    public function new() {}

    public function convert(char: String) -> String {
        final mapped = mapping.get(char);
        if(mapped != null) return mapped;
        return char;
    }
}