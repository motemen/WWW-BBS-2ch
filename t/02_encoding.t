use strict;
use warnings;
use utf8;
use Test::More;
use Test::MockObject;
use FindBin;
use File::Spec;
use WWW::BBS::2ch;

Test::MockObject->new->fake_module('URI::Fetch::Response', content => sub {
    open my $rfh, '<', File::Spec->catfile("$FindBin::Bin/dat/", "dummy.dat") or die "$!";
    my $content = do {local $/; <$rfh>};
    close $rfh;

    $content;
});
Test::MockObject->new->fake_module('URI::Fetch', fetch => sub {
    URI::Fetch::Response->new;
});

my $content = WWW::BBS::2ch->new->fetch('dummy', {cache => 1});

like $content, qr/㌧/, 'is not garbling?';

done_testing;
