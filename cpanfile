requires 'SQL::Maker' => '1.11';
requires 'DBI'        => '1.625';

on test => sub {
    requires 'Test::More', 0.98;
};

on configure => sub {
};

on 'develop' => sub {
};

