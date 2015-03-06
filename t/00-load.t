#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'Devel::Dependencies::Graph' ) || print "Bail out!\n";
}

diag( "Testing Devel::Dependencies::Graph $Devel::Dependencies::Graph::VERSION, Perl $], $^X" );
