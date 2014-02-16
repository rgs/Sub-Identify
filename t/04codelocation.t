#!perl
BEGIN { $ENV{PERL_SUB_IDENTIFY_PP} = 1 }
use Test::More tests => 4;
use Sub::Identify ':all';

sub newton {
    print;
    print;
    print;
    print;
    print;
    print;
    print;
}
*hooke = *newton;
for ( \&newton, \&hooke ) {
    my ($file, $line) = get_code_location($_);
    is( $file, 't/04codelocation.t' );
    is( $line, 7 );
}
