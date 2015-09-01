#!perl

use strict;
use Test::More tests => 4;
use Sub::Identify ':all';
use List::Util;

my ($file, $line);

($file, $line) = get_code_location \&List::Util::minstr;
ok !defined $file;
ok !defined $line;

($file, $line) = get_code_location \&Sub::Identify::get_code_location;
ok !defined $file;
ok !defined $line;
