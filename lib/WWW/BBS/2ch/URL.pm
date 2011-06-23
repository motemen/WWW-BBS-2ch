package WWW::BBS::2ch::URL;
use strict;
use warnings;
use Carp;
use Class::Accessor::Lite
    rw => [ qw(host board id) ],
    new => 1;

sub parse {
    my ($class, $url) = @_;

    if (my ($host, $board, $id) = $url =~ m#^http://(\w+\.(?:2ch\.net|\.bbspink\.com))/test/read.cgi/([^/]+)/(\d+)#) {
        return $class->new(
            host  => $host,
            board => $board,
            id    => $id,
        );
    }
    
    if (my ($host, $board) = $url =~ m#^http://(\w+\.(?:2ch\.net|bbspink\.com))/([^/]+)/#) {
        return $class->new(
            host  => $host,
            board => $board,
        );
    }

    confess "Could not parse URL: $url";
}

sub subject {
    my $self = shift;
    return sprintf 'http://%s/%s/subject.txt', $self->host, $self->board;
}

sub dat {
    my $self = shift;
    return sprintf 'http://%s/%s/dat/%s.dat', $self->host, $self->board, $self->id;
}

sub with_id {
    my ($self, $id) = @_;
    my $class = ref $self;
    return $class->new(
        host  => $self->host,
        board => $self->board,
        id    => $id,
    );
}

1;
