package Test::Factory;
use strict;
use warnings;
use 5.008005;
our $VERSION = "0.01";

use parent 'Exporter';

our @EXPORT = qw/factory/;

my %INSTANCE;
my %CLASS_SLOT;

sub import {
    my $class = shift;
    my $caller = scalar caller;

    require strict; import strict;
    require warnings; import warnings;

    do {
        no strict 'refs';
        *{"${caller}::dsn"}    = \&dsn;
        *{"${caller}::build"}  = \&build;
        *{"${caller}::create"} = \&create;
        *{"${caller}::attributes_for"} = \&attributes_for;
    };
    $INSTANCE{$caller} = +{ info => {} };

    $class->export_to_level(1, @_);
}

sub unimport {
    my $caller = scalar caller;
    no strict 'refs';
    delete ${"${caller}::"}{'factory'};
}

sub dsn {
    my $class = shift;
    $INSTANCE{$class}{db} ||= Test::Factory::DB->new(@_);
}

sub factory($@) {
    my $caller = scalar caller;
    my ($label, %args, $define);

    $label  = shift @_;
    $define = pop @_;
    %args   = @_ > 1 ? @_ : %{ $_[0] } if @_;
    my $db_table = $args{table} || $label;
    if (my $alias = $args{alias}) {
        my $alias_param = $INSTANCE{$caller}{info}{$alias};
        $db_table = $alias_param->{table};
        $INSTANCE{$caller}{info}{$label} = {
            table   => $db_table,
            columns => $define
        };
    }
    elsif (my $parent = $args{parent}) {
        my $parent_param = $INSTANCE{$caller}{info}{$parent};
        $db_table = $parent_param->{table};
        $INSTANCE{$caller}{info}{$label} = {
            table   => $db_table,
            columns => +{
                %{ $parent_param->{columns} },
                %$define
            }
        };
    }
    else {
        $INSTANCE{$caller}{info}{$label} = {
            table   => $db_table,
            columns => $define
        };
    }
}

sub _build {
    my ($class, $label, %args) = @_;

    my $params = $class->attributes_for($label) or return;

    my $new_class_name = 'Test::Factory::Product::__'.$label;
    $CLASS_SLOT{$new_class_name} ||= do {
        my $cls = qq[package $new_class_name;

use strict;
use warnings;

use parent -norequire => 'Test::Factory::Product';

use Class::Accessor::Lite;

sub new {
    my \$self = shift->SUPER::new(\@_);
    my \@cols = \@{ \$self->{meta}{cols} };
    Class::Accessor::Lite->mk_accessors(\@cols);
    return \$self;
}

1;];
        local $@; eval "$cls";
        $cls;
    };

    my %column = (%{ $params->{columns} }, %args);
    $new_class_name->new(
        meta => {
            table => $params->{table},
            db    => $INSTANCE{$class}{db},
            cols  => [keys %column]
        },
        %column
    );
}

sub attributes_for { $INSTANCE{$_[0]}{info}{$_[1]} }

sub build { _build(@_) }

sub create {
    my $ins = _build(@_) or return;
    $ins->save;
    $ins;
}

package Test::Factory::DB;

use strict;
use warnings;
use SQL::Maker;
use DBI;

sub new {
    my $class = shift;
    my $dbh   = DBI->connect(@_);
    my $maker = SQL::Maker->new(driver => $dbh->{Driver}{Name});
    bless { dbh => $dbh, maker => $maker }, $class;
}

sub insert {
    my $self = shift;
    my ($sql, @bind) = $self->{maker}->insert(@_);
    my $sth = $self->{dbh}->prepare($sql);
    $sth->execute(@bind);
}

package Test::Factory::Product;

use strict;
use warnings;

sub new {
    my ($class, %args) = @_;
    $args{meta}{created} = 0;
    for my $key (keys %args) {
        next if $key eq 'meta';
        if ((ref($args{$key})||'') eq 'CODE') {
            $args{$key} = $args{$key}->();
        }
    }
    bless \%args, $class;
}

sub created { shift->{meta}{created} }

sub save {
    my $self = shift;
    return if $self->{meta}{created};
    my $meta = $self->{meta};
    my $columns = $self->columns;
    $meta->{db}->insert($meta->{table}, $columns);
    ++$self->{meta}{created};
}

sub columns {
    my $self = shift;
    my @keys = @{ $self->{meta}{cols} };
    +{ map { $_ => $self->$_ } @keys};
}

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

