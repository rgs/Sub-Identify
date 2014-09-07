#!perl
BEGIN { $ENV{PERL_SUB_IDENTIFY_PP} = 1 }
use Test::More tests => 4;
use Sub::Identify 'is_sub_constant';

sub un;
sub deux ();
sub trois { 3 }
sub quatre () { 4 }

ok(!is_sub_constant(\&un));
ok(!is_sub_constant(\&deux));
ok(!is_sub_constant(\&trois));
ok(is_sub_constant(\&quatre));
