#!perl

use Test::More tests => 4;
use Sub::Identify ':all';
for my $f (qw(sub_name stash_name sub_fullname get_code_info)) {
    is(prototype($f), '$', "Prototype of $f is \$")
}
