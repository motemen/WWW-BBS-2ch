package WWW::BBS::2ch;
use strict;
use warnings;
use WWW::BBS::2ch::URL;
use WWW::BBS::2ch::Board;
use WWW::BBS::2ch::Thread;
use URI::Fetch;
use LWP::UserAgent;
use HTTP::Status qw(HTTP_OK HTTP_PARTIAL_CONTENT);
use Encode;
use Class::Accessor::Lite
    rw => [ qw(ua cache encoding) ];

our $VERSION = '0.01';

sub new {
    my $class = shift;
    return bless {
        ua => LWP::UserAgent->new(agent => 'Monazilla/1.00'),
        encoding => 'shift_jis',
        @_,
    }, $class;
}

# $api->fetch($url, { delta => 1 | 0, cache => 1 | 0 });
sub fetch {
    my ($self, $url, $option) = @_;

    if ($option->{cache}) {
        my $res = URI::Fetch->fetch($url, Cache => $self->cache, NoNetwork => 1)
            or return undef;
        return decode($self->encoding, $res->content);
    }

    my $cached_content;
    if ($option->{delta}) {
        if (my $cached_res = URI::Fetch->fetch($url, Cache => $self->cache, NoNetwork => 1)) {
            $cached_content = $cached_res->content;
        }
    }

    $self->ua->set_my_handler(
        request_prepare => $cached_content && sub {
            my $req = shift;
            if ($req->uri eq $url) {
                $req->remove_header('Accept-Encoding');
                $req->push_header(Range => sprintf('bytes=%d-', length($cached_content) - 1));
            }
        }
    );

    $self->ua->set_my_handler(
        response_done => $cached_content && sub {
            my $res = shift;
            if ($res->request->uri eq $url && $res->code == HTTP_PARTIAL_CONTENT) {
                $res->code(HTTP_OK);
                $res->remove_header('Content-Range');
                $res->content($cached_content . $res->content);
                $res->header('Content-Length' => length $res->content);
            }
        }
    );

    my $res = URI::Fetch->fetch($url, UserAgent => $self->ua, Cache => $self->cache)
        or die URI::Fetch->errstr;

    return decode($self->encoding, $res->content);
}

sub get_board {
    my ($self, $url) = @_;
    $url = WWW::BBS::2ch::URL->parse($url);
    return WWW::BBS::2ch::Board->new(
        url => $url,
        api => $self,
    );
}

sub get_thread {
    my ($self, $url) = @_;
    $url = WWW::BBS::2ch::URL->parse($url);
    return WWW::BBS::2ch::Thread->new(
        url => $url,
        api => $self,
    );
}

1;

__END__

=head1 NAME

WWW::BBS::2ch -

=head1 SYNOPSIS

  use WWW::BBS::2ch;

=head1 DESCRIPTION

WWW::BBS::2ch is

=head1 AUTHOR

motemen E<lt>motemen@gmail.comE<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
