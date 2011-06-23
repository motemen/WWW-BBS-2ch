use strict;
use warnings;
use Test::More;
use WWW::BBS::2ch::URL;

my $board_url = WWW::BBS::2ch::URL->parse('http://kamome.2ch.net/sf/');
isa_ok $board_url, 'WWW::BBS::2ch::URL';
is $board_url->subject, 'http://kamome.2ch.net/sf/subject.txt';

my $thread_url = $board_url->with_id('1306953515');
isa_ok $thread_url, 'WWW::BBS::2ch::URL';
is $thread_url->dat,  'http://kamome.2ch.net/sf/dat/1306953515.dat';

done_testing;
