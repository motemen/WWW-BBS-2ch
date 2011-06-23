package WWW::BBS::2ch::Thread;
use strict;
use warnings;
use WWW::BBS::2ch::Res;
use Class::Accessor::Lite rw => [ qw(api url title res_list) ];

sub new {
    my $class = shift;

    return bless {
        res_list => [],
        @_,
    }, $class;
}

sub update {
    my $self = shift;

    $self->res_list([]);

    my $content = $self->api->fetch($self->url->dat, { delta => 1 });
    my $no = 1;
    foreach (split /\n/, $content) {
        my ($name, $mail, $meta, $html_body) = split /<>/, $_ or next;
        my $res = WWW::BBS::2ch::Res->new(
            name      => $name,
            mail      => $mail,
            meta      => $meta,
            html_body => $html_body,
            no        => $no++,
        );
        push @{ $self->res_list }, $res;
    }
}

1;
