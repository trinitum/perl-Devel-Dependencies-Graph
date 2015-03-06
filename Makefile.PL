use 5.008;
use strict;
use warnings;
use ExtUtils::MakeMaker 6.64;

WriteMakefile(
    NAME                => 'Devel::Dependencies::Graph',
    AUTHOR              => q{Pavel Shaydo <zwon@cpan.org>},
    VERSION_FROM        => 'lib/Devel/Dependencies/Graph.pm',
    ABSTRACT_FROM       => 'lib/Devel/Dependencies/Graph.pm',
    LICENSE             => 'perl',
    PL_FILES            => {},
    PREREQ_PM => {
    },
    TEST_REQUIRES => {
        'Test::More' => 0.94,
    },
    CONFIGURE_REQUIRES => {
        'ExtUtils::MakeMaker' => 6.64,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'Devel-Dependencies-Graph-*' },
    META_MERGE => {
        no_index => {
            file => 'README.pod'
        },
        resources => {

            homepage   => 'https://github.com/trinitum/perl-Devel-Dependencies-Graph',
            bugtracker => 'https://github.com/trinitum/perl-Devel-Dependencies-Graph/issues',
            repository => 'git://github.com/trinitum/perl-Devel-Dependencies-Graph',

            license    => 'http://dev.perl.org/licenses/',
        },
    },
);
