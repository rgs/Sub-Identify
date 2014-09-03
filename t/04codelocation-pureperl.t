#!perl
BEGIN { $ENV{PERL_SUB_IDENTIFY_PP} = 1 }
use Test::More tests => 6;
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
    is( $file, 't/04codelocation-pureperl.t', 'file' );
    is( $line, 7, 'line' );
}
{
    sub pauli;
    my ($file, $line) = get_code_location(\&pauli);
    ok( !defined $file, 'no definition, no file' );
    ok( !defined $line, 'no definition, no line' );
}
