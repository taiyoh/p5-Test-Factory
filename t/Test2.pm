package t::Test2;

use Test::Factory;

factory foo => {
    col1 => 'aaa',
    col2 => 1,
    col3 => 'iii'
};

no Test::Factory;

1;
