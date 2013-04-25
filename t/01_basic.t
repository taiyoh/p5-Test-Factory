use strict;
use Test::More;

use t::Util;

my $mysqld = Test::mysqld->new(
    my_cnf => {
      'skip-networking' => '', # no TCP socket
    }
) or plan skip_all => $Test::mysqld::errstr;

my $dbh = DBI->connect($mysqld->dsn(dbname => 'test'));

$dbh->do(q[
create table foo (
  id int unsigned not null auto_increment,
  col1 varchar(10) not null,
  col2 int not null,
  col3 varchar(10) not null,
  primary key(id)
)
]);

use t::Test1;
use t::Test2;

t::Test1->dsn($mysqld->dsn(dbname => 'test'));

ok(t::Test1->can('factory'));
ok(!t::Test2->can('factory'));

my $foo1 = t::Test1->build('foo');
ok $foo1;
ok !$foo1->created;
is $foo1->col1, 'aaa';
is $foo1->col2, 0;

my $foo2 = t::Test1->create('foo');
ok $foo2;
ok $foo2->created;
is $foo2->col1, 'aaa';
is $foo2->col2, 1;

my $bar1 = t::Test1->create('bar');
ok $bar1;
ok $bar1->created;
is $bar1->col2, 2;
is $bar1->col3, 'uuuuu';

do {
    my $sth = $dbh->prepare('select * from foo');
    $sth->execute;
    is $sth->rows, 2;
};

my $baz1 = t::Test1->build('baz');
ok $baz1;
is $baz1->col1, 'eeee';
is $baz1->col2, 3;
is $baz1->col3, 'oo00';

my $foo_bar1 = t::Test1->build('foo_bar');
ok $foo_bar1;
is $foo_bar1->col1, '!!!!';
is $foo_bar1->col2, 20;
is $foo_bar1->col3, 'ZZZZ';

my $foo3 = t::Test1->build('foo');
is $foo3->col2, 3;

done_testing;
