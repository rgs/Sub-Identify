use 5.006;
use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME          => 'Sub::Identify',
    ABSTRACT      => 'Retrieve names of code references',
    VERSION_FROM  => 'lib/Sub/Identify.pm',
    LICENSE       => 'perl',
    PREREQ_PM     => {
        ( ( parse_args()->{PUREPERL_ONLY} or !can_xs() )
            ? ()
            : ('Sub::Identify::XS' => 0)
        ),
        'Test::More'  => 0,
    },
    META_ADD => {
        'meta-spec' => { version => 2 },
        prereqs => {
            runtime => { requires => {}, },
            test => { requires => {
                'Test::More' => 0,
            } },
            configure => { requires => {
                'ExtUtils::CBuilder' => 0.27,
            } },
        },
    },
    META_MERGE => {
        'meta-spec' => { version => 2 },
        resources => {
            repository => {
                type  => 'git',
                url   => 'git://github.com/rgs/Sub-Identify',
                web   => 'https://github.com/rgs/Sub-Identify',
            },
        },
    },
);

use Text::ParseWords;
BEGIN { if ( $^O eq 'cygwin' ) {
  require ExtUtils::MM_Cygwin;
  require ExtUtils::MM_Win32;
  if ( ! defined(&ExtUtils::MM_Cygwin::maybe_command) ) {
    *ExtUtils::MM_Cygwin::maybe_command = sub {
      my ($self, $file) = @_;
      if ($file =~ m{^/cygdrive/}i and ExtUtils::MM_Win32->can('maybe_command')) {
        ExtUtils::MM_Win32->maybe_command($file);
      } else {
        ExtUtils::MM_Unix->maybe_command($file);
      }
    }
  }
}}

sub parse_args {
  # copied from EUMM
  ExtUtils::MakeMaker::parse_args(
    my $tmp = {},
    Text::ParseWords::shellwords($ENV{PERL_MM_OPT} || ''),
    @ARGV,
  );
  return $tmp->{ARGS} || {};
}

BEGIN {
  if (eval { require Sub::Identify }
      && Sub::Identify->VERSION < 0.04) {
    package MY;
    no warnings 'once';

    *install = sub {
      my $self = shift;
      return
        "pure_site_install ::\n"
        . "\t$(NOECHO) $(RM_F) " . $self->quote_literal(
          $self->catfile('$(DESTINSTALLSITEARCH)', 'Sub', 'Identify.pm')
        ) . "\n"
        . $self->SUPER::install;
    };
  }
}

# can we locate a (the) C compiler
sub can_cc {
  my @chunks = split(/ /, $Config::Config{cc}) or return;

  # $Config{cc} may contain args; try to find out the program part
  while (@chunks) {
    return can_run("@chunks") || (pop(@chunks), next);
  }

  return;
}

# check if we can run some command
sub can_run {
  my ($cmd) = @_;

  return $cmd if -x $cmd;
  if (my $found_cmd = MM->maybe_command($cmd)) {
    return $found_cmd;
  }

  require File::Spec;
  for my $dir ((split /$Config::Config{path_sep}/, $ENV{PATH}), '.') {
    next if $dir eq '';
    my $abs = File::Spec->catfile($dir, $cmd);
    return $abs if (-x $abs or $abs = MM->maybe_command($abs));
  }

  return;
}

# Can our C compiler environment build XS files
sub can_xs {
  # Do we have the configure_requires checker?
  local $@;
  eval "require ExtUtils::CBuilder; ExtUtils::CBuilder->VERSION(0.27)";
  if ( $@ ) {
    # They don't obey configure_requires, so it is
    # someone old and delicate. Try to avoid hurting
    # them by falling back to an older simpler test.
    return can_cc();
  }

  # Do we have a working C compiler
  my $builder = ExtUtils::CBuilder->new(
    quiet => 1,
  );
  unless ( $builder->have_compiler ) {
    # No working C compiler
    return 0;
  }

  # Write a C file representative of what XS becomes
  require File::Temp;
  my ( $FH, $tmpfile ) = File::Temp::tempfile(
    "compilexs-XXXXX",
    SUFFIX => '.c',
  );
  binmode $FH;
  print $FH <<'END_C';
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

int main(int argc, char **argv) {
    return 0;
}

int boot_sanexs() {
    return 1;
}

END_C
  close $FH;

  # Can the C compiler access the same headers XS does
  my @libs   = ();
  my $object = undef;
  eval {
    local $^W = 0;
    $object = $builder->compile(
      source => $tmpfile,
    );
    @libs = $builder->link(
      objects     => $object,
      module_name => 'sanexs',
    );
  };
  my $result = $@ ? 0 : 1;

  # Clean up all the build files
  foreach ( $tmpfile, $object, @libs ) {
    next unless defined $_;
    1 while unlink;
  }

  return $result;
}
