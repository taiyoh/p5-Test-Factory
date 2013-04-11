package Test::Factory;
use strict;
use warnings;
use 5.008005;
our $VERSION = "0.01";

use parent 'Exporter';
use DBI;
use Carp ();

our @EXPORT = qw/define build create/;

my %INSTANCE;

sub define {
}

sub _build {
    my ($caller, $args) = @_;
}

sub build {
    my $caller = scalar caller;
    _build($caller, @_);
}

sub create {
    my $caller = scalar caller;
    my $ins = _build($caller, @_);
}

package Test::Factory::Product;

use SQL::Maker;

sub new {}

sub save {}

1;
__END__

=encoding utf-8

=head1 NAME

Test::Factory - It's new $module

=head1 SYNOPSIS

    use Test::Factory;

=head1 DESCRIPTION

Test::Factory is ...

=head1 LICENSE

Copyright (C) taiyoh

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

taiyoh E<lt>sun.basix@gmail.comE<gt>

