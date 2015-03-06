package Devel::Dependencies::Graph;
use 5.010;
use strict;
use warnings;
our $VERSION = "0.01";
$VERSION = eval $VERSION;

=head1 NAME

Devel::Dependencies::Graph - create dependency graph for packages

=head1 VERSION

This document describes Devel::Dependencies::Graph version 0.01

=head1 SYNOPSIS

    use Devel::Dependencies::Graph;

=head1 DESCRIPTION

=head1 METHODS

=cut

use Moose;
with 'MooseX::Getopt';

use Path::Tiny;
use Pod::Strip;

has root_dir => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
);

has prefix => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
);

has output => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
);

has _deps => (
    is      => 'ro',
    default => sub { {} },
);

sub run {
    my $self = shift;
    my $root = path( $self->root_dir );
    say "looking in " . $root->realpath;
    my @modules;
    my @dirs  = ($root);
    my $depth = 10;

    while ( @dirs and $depth-- ) {
        my @more_dirs;
        for (@dirs) {
            push @modules, $_->children(qr/.*\.pm/);
            push @more_dirs, grep { $_->is_dir } $_->children;
        }
        @dirs = @more_dirs;
    }

    say "found " . scalar(@modules) . " files";
    for (@modules) {
        $self->_find_dependencies_of($_);
    }

    $self->_generate_digraph;
}

sub _find_dependencies_of {
    my ( $self, $file ) = @_;

    my $text = $file->slurp;
    my $ps   = Pod::Strip->new;
    my $podless;
    $ps->output_string( \$podless );
    $ps->parse_string_document($text);
    my $package;

    for ( split /^/, $podless ) {
        chomp;
        if ( not $package and /^\s*package\s+([A-Za-z_:]+)/ ) {
            $package = $1;
            return unless $package =~ s/^$self->{prefix}:*//;
        }
        next unless $package;
        if (/^\s+use\s+(?:base|parent)\s*([A-Za-z_:]+)/) {
            $self->_add_dep( $package, 'extends', $1 );
        }
        elsif (/^\s*use\s+([A-Za-z_:]+)/) {
            $self->_add_dep( $package, 'use', $1 );
        }
        elsif (/^\s*require\s+([A-Za-z_:]+)/) {
            $self->_add_dep( $package, 'use', $1 );
        }
        elsif (/^\s*extends\s+["']([A-Za-z_:]+)/) {
            $self->_add_dep( $package, 'extends', $1 );
        }
        elsif (/^\s*with\s+["']([A-Za-z_:]+)/) {
            $self->_add_dep( $package, 'with', $1 );
        }
    }
}

sub _add_dep {
    my ( $self, $package, $type, $dep ) = @_;
    return unless $dep =~ s/^$self->{prefix}:*//;
    $self->{_deps}{$dep}{$type}{$package} = 1;
}

my %style = (
    extends => 'bold',
    with    => 'solid',
    use     => 'dashed',
);

sub _generate_digraph {
    my $self = shift;
    my $fh   = path( $self->output )->openw;
    say $fh "digraph {";
    my $deps = $self->{_deps};
    for my $dependency ( sort keys %$deps ) {
        for my $type (qw(extends with use)) {
            for my $package ( sort keys %{ $deps->{$dependency}{$type} } ) {
                say $fh
                  sprintf( '    "%s"->"%s"[style=%s]', $dependency, $package, $style{$type} );
            }
        }
    }
    say $fh "}";
    close $fh;
}

1;

__END__

=head1 BUGS

Please report any bugs or feature requests via GitHub bug tracker at
L<http://github.com/trinitum/perl-Devel-Dependencies-Graph/issues>.

=head1 AUTHOR

Pavel Shaydo C<< <zwon at cpan.org> >>

=head1 LICENSE AND COPYRIGHT

Copyright (C) 2015 Pavel Shaydo

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.

=cut
