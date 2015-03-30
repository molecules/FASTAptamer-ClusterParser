#!/bin/env perl6
sequence().join('').say for 1 .. 10;

sub sequence {
   return "ACDEFGHIKLMNPQRSTVWY".split('').pick(20);
}
