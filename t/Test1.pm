package t::Test1;

use Test::Factory;

my $foo_counter = 0;

factory foo => {
    col1 => 'aaa',
    col2 => sub { $foo_counter++ },
    col3 => 'iii'
};

factory bar => { parent => 'foo' }, {
    col3 => 'uuuuu'
};

factory baz => { alias => 'foo' }, {
    col1 => 'eeee',
    col2 => 3,
    col3 => 'oo00'
};

factory foo_bar => { table => 'foo' }, {
    col1 => '!!!!',
    col2 => 20,
    col3 => 'ZZZZ'
};

1;
