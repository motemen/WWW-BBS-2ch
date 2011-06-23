use inc::Module::Install;

name 'WWW-BBS-2ch';
all_from 'lib/WWW/BBS/2ch.pm';

# requires '';

tests 't/*.t';
author_tests 'xt';

test_requires 'Test::More';

auto_set_repository;
auto_include;

WriteAll;
