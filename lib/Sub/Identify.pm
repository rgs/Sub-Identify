package Sub::Identify;

use strict;
use Exporter;

BEGIN {
    our $VERSION = '0.04';
    our @ISA = ('Exporter');
    our %EXPORT_TAGS = (
        all => [
            our @EXPORT_OK = qw(sub_name stash_name sub_fullname get_code_info get_code_location)
        ]
    );

    our $IsPurePerl = 1;
    unless ($ENV{PERL_SUB_IDENTIFY_PP}) {
        if (
            eval {
                require Sub::Identify::XS;
            }
        ) {
            Sub::Identify::XS->import(':all');
            $IsPurePerl = 0;
        }
        elsif (! ($@ && $@ =~ m{\ACan't locate Sub/Identify/XS\.pm })) {
            die $@;
        }
    }

    if (!defined &get_code_info) {
        require B;
        *get_code_info = sub ($) {
            my ($coderef) = @_;
            ref $coderef or return;
            my $cv = B::svref_2object($coderef);
            $cv->isa('B::CV') or return;
            # bail out if GV is undefined
            $cv->GV->isa('B::SPECIAL') and return;

            return ($cv->GV->STASH->NAME, $cv->GV->NAME);
        };
    }

    if (!defined &get_code_location) {
        require B;
        *get_code_location = sub ($) {
            my ($coderef) = @_;
            ref $coderef or return;
            my $cv = B::svref_2object($coderef);
            $cv->isa('B::CV') or return;

            return ($cv->START->file, $cv->START->line);
        };
    }
}

sub stash_name   ($) { (get_code_info($_[0]))[0] }
sub sub_name     ($) { (get_code_info($_[0]))[1] }
sub sub_fullname ($) { join '::', get_code_info($_[0]) }

1;

__END__

=head1 NAME

Sub::Identify - Retrieve names of code references

=head1 SYNOPSIS

    use Sub::Identify ':all';
    my $subname = sub_name( $some_coderef );
    my $p = stash_name( $some_coderef );
    my $fully_qualified_name = sub_fullname( $some_coderef );
    defined $subname
    and print "this coderef points to sub $subname in package $p\n";

=head1 DESCRIPTION

C<Sub::Identify> allows you to retrieve the real name of code references.

It provides four functions : C<sub_name> returns the name of the
subroutine (or C<__ANON__> if it's an anonymous code reference),
C<stash_name> returns its package, and C<sub_fullname> returns the
concatenation of the two.

The fourth function, C<get_code_info>, returns a list of two elements,
the package and the subroutine name (in case of you want both and are worried
by the speed.)

In case of subroutine aliasing, those functions always return the
original name.

=head2 Pure-Perl version

By default C<Sub::Identify> tries to load an XS implementation of the
C<get_code_info> function, for speed; if that fails, or if the environment
variable PERL_SUB_IDENTIFY_PP is defined to a true value, it will fall
back to a pure perl implementation, that uses perl's introspection mechanism,
provided by the C<B> module.

=head1 SEE ALSO

L<Sub::Name>

=head1 SOURCE

A git repository for the sources is at L<https://github.com/rgs/Sub-Identify>.

=head1 LICENSE

(c) Rafael Garcia-Suarez (rgs at consttype dot org) 2005, 2008, 2012

This program is free software; you may redistribute it and/or modify it under
the same terms as Perl itself.

=cut
