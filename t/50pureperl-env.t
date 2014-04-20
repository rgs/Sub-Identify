#!perl

BEGIN { $ENV{PERL_SUB_IDENTIFY_PP} = 1 }

use Test::More tests => 1;

use Sub::Identify;

ok($Sub::Identify::IsPurePerl, "running a pure-perl Sub::Identify");
