requires 'SQL::Maker' => '1.11';
requires 'DBI'        => '1.625';
requires 'DBD::mysql' => '4.023';
requires 'Class::Accessor::Lite' => '0.05';

on test => sub {
    requires 'Test::More', 0.98;
    requires 'Test::mysqld' => '0.17';
};

on configure => sub {
};

on 'develop' => sub {
};

