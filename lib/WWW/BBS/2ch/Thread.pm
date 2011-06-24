package WWW::BBS::2ch::Thread;
use strict;
use warnings;
use WWW::BBS::2ch::Res;
use Class::Accessor::Lite rw => [ qw(api url title content res_list) ];

sub new {
    my $class = shift;

    return bless {
        res_list => [],
        @_,
    }, $class;
}

sub update {
    my $self = shift;
    my $content = $self->api->fetch($self->url->dat, { delta => 1 });
    $self->_update_content_and_parse($content);
}

sub recall {
    my $self = shift;
    my $content = $self->api->fetch($self->url->dat, { cache => 1 });
    $self->_update_content_and_parse($content);
}

sub _update_content_and_parse {
    my ($self, $content) = @_;

    return 0 unless defined $content;

    $self->content($content);
    $self->parse;
    return 1;
}

sub parse {
    my $self = shift;

    $self->res_list([]);

    my $no = 1;
    foreach (split /\n/, $self->content) {
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
