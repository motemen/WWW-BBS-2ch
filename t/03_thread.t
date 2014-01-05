use strict;
use warnings;
use utf8;
use Test::More;
use WWW::BBS::2ch;

subtest 'Strings with code points over 0xFF may not be mapped into in-memory file handles' => sub {
    plan skip_all => 'version is less then 5.18' if $^V lt v5.18.0;
    plan skip_all => 'set TEST_LIVE to run this test' unless $ENV{TEST_LIVE};

    my $bbs = WWW::BBS::2ch->new;
    my $board = $bbs->get_board('http://headline.2ch.net/bbynamazu/');
    $board->update;
    my $thread = $board->thread_list->[0];
    $thread->update;
    $thread->parse;

    cmp_ok @{ $thread->res_list }, '>', 0, 'res_list > 0';
};

done_testing;
