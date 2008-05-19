#!perl

use Test::More tests => 4;
use Sub::Identify ':all';

ok( !defined sub_name( undef ) );
ok( !defined sub_name( "scalar" ) );
ok( !defined sub_name( \"scalar ref" ) );
ok( !defined sub_name( \@INC ) );
