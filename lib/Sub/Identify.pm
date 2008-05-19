package Sub::Identify;

use B ();
use Exporter;

$VERSION = '0.02';
@ISA = ('Exporter');
%EXPORT_TAGS = (all => [ @EXPORT_OK = qw(sub_name stash_name sub_fullname) ]);

use strict;

sub _cv {
    my ($coderef) = @_;
    ref $coderef or return undef;
    my $cv = B::svref_2object($coderef);
    $cv->isa('B::CV') ? $cv : undef;
}

sub sub_name {
    my $cv = &_cv or return undef;
    $cv->GV->NAME;
}

sub stash_name {
    my $cv = &_cv or return undef;
    $cv->GV->STASH->NAME;
}

sub sub_fullname {
    my $cv = &_cv or return undef;
    $cv->GV->STASH->NAME . '::' . $cv->GV->NAME;
}

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

C<Sub::Identify> allows you to retrieve the real name of code references. For
this, it uses perl's introspection mechanism, provided by the C<B> module.

It provides three functions : C<sub_name> returns the name of the
subroutine (or C<__ANON__> if it's an anonymous code reference),
C<stash_name> returns its package, and C<sub_fullname> returns the
concatenation of the two.

In case of subroutine aliasing, those functions always return the
original name.

=head1 AUTHOR

Written by Rafael Garcia-Suarez (rgarciasuarez at mandriva dot com).

This program is free software; you may redistribute it and/or modify it under
the same terms as Perl itself.

=cut
