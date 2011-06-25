package WWW::BBS::2ch::URL;
use strict;
use warnings;
use Carp;
use Class::Accessor::Lite
    rw => [ qw(host board_key id) ],
    new => 1;

sub parse {
    my ($class, $url) = @_;

    if (my ($host, $board_key, $id) = $url =~ m#^http://(\w+\.(?:2ch\.net|bbspink\.com))/test/read\.cgi/([^/]+)/(\d+)#) {
        return $class->new(
            host      => $host,
            board_key => $board_key,
            id        => $id,
        );
    }

    if (my ($host, $board_key, $id) = $url =~ m#^http://(\w+\.(?:2ch\.net|bbspink\.com))/([^/]+)/dat/(\d+)\.dat#) {
        return $class->new(
            host      => $host,
            board_key => $board_key,
            id        => $id,
        );
    }
    
    if (my ($host, $board_key) = $url =~ m#^http://(\w+\.(?:2ch\.net|bbspink\.com))/([^/]+)/#) {
        return $class->new(
            host      => $host,
            board_key => $board_key,
        );
    }

    croak "Could not parse URL: $url";
}

sub subject {
    my $self = shift;
    return sprintf 'http://%s/%s/subject.txt', $self->host, $self->board_key;
}

sub dat {
    my $self = shift;
    return sprintf 'http://%s/%s/dat/%s.dat', $self->host, $self->board_key, $self->id;
}

sub board {
    my $self = shift;
    return sprintf 'http://%s/%s/', $self->host, $self->board_key;
}

sub thread {
    my $self = shift;
    return sprintf 'http://%s/test/read.cgi/%s/%s', $self->host, $self->board_key, $self->id;
}

sub dat_kako {
    my $self = shift;
    if (length $self->id >= 10) {
        return sprintf 'http://%s/%s/kako/%s/%s/%s.dat', $self->host, $self->board_key, substr($self->id, 0, 4), substr($self->id, 0, 5), $self->id;
    } else {
        return sprintf 'http://%s/%s/kako/%s/%s.dat', $self->host, $self->board_key, substr($self->id, 0, 3), $self->id;
    }
}

sub dat_kako_gz {
    my $self = shift;
    return $self->dat_kako . '.gz';
}

sub with_id {
    my ($self, $id) = @_;
    my $class = ref $self;
    return $class->new(
        host      => $self->host,
        board_key => $self->board_key,
        id        => $id,
    );
}

1;
