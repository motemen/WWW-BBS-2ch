package WWW::BBS::2ch;
use strict;
use warnings;
use WWW::BBS::2ch::URL;
use WWW::BBS::2ch::Board;
use WWW::BBS::2ch::Thread;
use Encode;
use LWP::UserAgent;
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

sub fetch {
    my ($self, $url) = @_;
    my $res = $self->ua->get($url);
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
