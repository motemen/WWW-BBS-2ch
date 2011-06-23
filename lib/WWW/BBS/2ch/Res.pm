package WWW::BBS::2ch::Res;
use strict;
use warnings;
use Class::Accessor::Lite rw => [ qw(name mail meta html_body no) ], new => 1;

sub body {
    my $self = shift;
    return $self->{body} if defined $self->{body};
    return $self->{body} = do {
        my $body = $self->html_body;
        $body =~ s/<br>/\n/g;
        $body =~ s/<.*?>//g;
        $body =~ s/^ | $//gm;
        $body =~ s/&lt;/</g;
        $body =~ s/&gt;/>/g;
        $body =~ s/&quot;/"/g;
        $body =~ s/&amp;/&/g;
        $body;
    };
}

1;
