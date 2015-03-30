#!/bin/env perl6
for lines() -> $header, $sequence
{
    say $header;
    my $length = length $sequence;
    say substr $sequence, 0, $length -3;
}
