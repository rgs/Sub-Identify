#!perl

use Test::More tests => 20;

BEGIN { use_ok 'Sub::Identify', ':all' }

sub buffy { }
sub vamp::spike { }
*slayer = *buffy;
*human::william = \&vamp::spike;

is( sub_name( \&sub_name ), 'sub_name' );
is( sub_name( \&buffy ), 'buffy' );
is( sub_name( \&vamp::spike ), 'spike' );
is( sub_name( \&slayer ), 'buffy' );
is( sub_name( \&human::william ), 'spike' );

is( stash_name( \&stash_name ), 'Sub::Identify' );
is( stash_name( \&buffy ), 'main' );
is( stash_name( \&vamp::spike ), 'vamp' );
is( stash_name( \&slayer ), 'main' );
is( stash_name( \&human::william ), 'vamp' );

is( sub_fullname( \&sub_fullname ), 'Sub::Identify::sub_fullname' );
is( sub_fullname( \&buffy ), 'main::buffy' );
is( sub_fullname( \&vamp::spike ), 'vamp::spike' );
is( sub_fullname( \&slayer ), 'main::buffy' );
is( sub_fullname( \&human::william ), 'vamp::spike' );

sub xander;
is( sub_name( \&xander ), 'xander', 'undefined subroutine' );

is( sub_name( sub {} ), '__ANON__' );
my $anon = sub {};
is( stash_name( $anon ), 'main' );
is( sub_fullname( $anon ), 'main::__ANON__' );
