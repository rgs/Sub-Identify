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
        'Test::More'  => 0,
    },
);
