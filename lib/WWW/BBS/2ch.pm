package WWW::BBS::2ch;
use strict;
use warnings;
use WWW::BBS::2ch::URL;
use WWW::BBS::2ch::Board;
use WWW::BBS::2ch::Thread;
use URI::Fetch;
use LWP::UserAgent;
use HTTP::Status ':constants';
use Encode;
use Class::Accessor::Lite
    rw => [ qw(ua cache encoding) ];

our $VERSION = '0.01';

sub new {
    my $class = shift;
    my $self = bless {
        ua => LWP::UserAgent->new(agent => "Monazilla/1.00 WWW::BBS::2ch/$VERSION"),
        encoding => 'shift_jis',
        @_,
    }, $class;

    $self->ua->add_handler(
        response_done => sub {
            my $res = shift;
            # 人大杉、バーボンなどは 302 になる
            if ($res->code eq HTTP_FOUND) {
                $res->code(HTTP_FORBIDDEN);
                $res->message(HTTP::Status::status_message($res->code));
            }
            # dat 落ち、過去ログ倉庫にある場合は 203 になる
            if ($res->code eq HTTP_NON_AUTHORITATIVE_INFORMATION) {
                $res->code(HTTP_GONE);
                $res->message(HTTP::Status::status_message($res->code));
            }
        }
    );
    $self->ua->max_redirect(0);

    return $self;
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

    my $res = URI::Fetch->fetch($url, UserAgent => $self->ua, Cache => $self->cache) or return undef;

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

WWW::BBS::2ch - 2ch.net/bbspink client

=head1 SYNOPSIS

  use WWW::BBS::2ch;

  my $bbs = WWW::BBS::2ch->new(cache => $cache, ua => $ua);
  
  my $board = $bbs->get_board('http://kamome.2ch.net/sf/');
  $board->update;

  my $thread = $board->thread_list->[0];
  # or
  my $thread = $bbs->get_thread('http://kamome.2ch.net/test/read.cgi/sf/1303882030/');

  $thread->update;
  # or if you want to get cached data
  $thread->recall; 

  $thread->parse;

  foreach my $res (@{ $thread->res_list }) {
      say $res->body;
  }

=head1 DESCRIPTION

WWW::BBS::2ch provides 2ch.net/bbspink retrieval methods.

=head1 AUTHOR

motemen E<lt>motemen@gmail.comE<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
