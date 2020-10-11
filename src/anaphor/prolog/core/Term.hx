// Copyright © 2020, David N Main. All rights reserved.
// Licensed under the MIT License, see LICENSE file for details.

package anaphor.prolog.core;

enum Term {
    InternedAtom;
    Atom;
    Variable;
    AttributedVariable;
    Struct;
    Integer;
    Float;
    String;
    Array;
    Vector;
    Dictionary;
}