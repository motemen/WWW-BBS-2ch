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
    if (defined $content) {
        $self->content($content);
    }
    return $content;
}

sub recall {
    my $self = shift;
    my $content = $self->api->fetch($self->url->dat, { cache => 1 });
    if (defined $content) {
        $self->content($content);
    }
    return $content;
}

sub parse {
    my $self = shift;

    return unless defined $self->content;

    $self->res_list([]);

    my $no = 1;
    foreach (split /\n/, $self->content) {
        next unless defined $_ && length $_;
        my ($name, $mail, $meta, $html_body, $title) = split /<>/, $_ or return 0;
        if (defined $title && !defined $self->title) {
            $self->title($title);
        }
        return 0 unless defined $html_body;
        my $res = WWW::BBS::2ch::Res->new(
            name      => $name,
            mail      => $mail,
            meta      => $meta,
            html_body => $html_body,
            no        => $no++,
        );
        push @{ $self->res_list }, $res;
    }

    return 1;
}

1;
