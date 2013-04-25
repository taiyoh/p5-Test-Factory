requires 'SQL::Maker' => '1.11';
requires 'DBI'        => '1.625';
requires 'DBD::mysql' => '0';

on test => sub {
    requires 'Test::More', 0.98;
    requires 'Test::mysqld' => '0';
};

on configure => sub {
};

on 'develop' => sub {
};

