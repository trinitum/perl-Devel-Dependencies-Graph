#!/usr/bin/env perl
use 5.010;
use Devel::Dependency::Graph;

Devel::Dependency::Graph->new_with_options->run;
