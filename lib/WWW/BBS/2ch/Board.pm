package WWW::BBS::2ch::Board;
use strict;
use warnings;
use Class::Accessor::Lite
    rw => [ qw(api url content thread_list) ];

sub new {
    my $class = shift;
    return bless {
        thread_list => [],
        @_
    }, $class;
}

sub update {
    my $self = shift;

    $self->thread_list([]);

    my $content = $self->api->fetch($self->url->subject);

    foreach (split /\n/, $content) {
        my ($id, $title, $count) = /^(\d+)\.dat<>(.+?)\((\d+)\)$/;
        my $thread = WWW::BBS::2ch::Thread->new(
            api   => $self->api,
            url   => $self->url->with_id($id),
            title => $title,
        );
        push @{ $self->thread_list }, $thread;
    }
}

1;
