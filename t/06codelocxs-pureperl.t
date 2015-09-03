#!perl

BEGIN { $ENV{PERL_SUB_IDENTIFY_PP} = 1 }
use strict;
use Test::More tests => 2;
use Sub::Identify ':all';
use List::Util;

my ($file, $line);

($file, $line) = get_code_location \&List::Util::minstr;
ok !defined $file;
ok !defined $line;
