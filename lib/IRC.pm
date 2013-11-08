package IRC;
use strict;
use warnings;
use Socket qw(pack_sockaddr_in inet_aton);
use Moose;

has 'sock' => ( is => 'ro', );
has 'server' => (
    is      => 'ro',
    isa     => 'Str',
    default => 'irc.freenode.net',
);
has 'port' => (
    is      => 'ro',
    isa     => 'Int',
    default => 6667,
);
has 'channel' => (
    is  => 'rw',
    isa => 'ArrayRef[Str]',
);
has 'nick' => (
    is      => 'ro',
    isa     => 'Str',
    default => join( '', map { ( "a" .. "z" )[ rand 26 ] } 1 .. 8 ),
);

sub DEMOLISH {
    my $self = shift;
    close( $self->{sock} ) if $self->{sock};
}

sub connect {
    my $self = shift;
    connect( $self->{sock},
        pack_sockaddr_in( $self->{port}, inet_aton( $self->{server} ) ) )
      or die "connect: $!";
    $self->login;
}

sub login {
    my $self = shift;
    my $sock = $self->{sock};
    send( $sock, "NICK $self->{nick}\r\n", 0 );
    send( $sock, "USER $self->{nick} 8 * $self->{nick}\r\n", 0 );
}

sub join_chan {
    my $self = shift;
    my $sock = $self->{sock};
    foreach my $chan ( @{ $self->{channel} } ) {
        send( $sock, "JOIN $chan\r\n", 0 );
    }

}

sub read {
    my $self = shift;
    my $sock = $self->{sock};
    while (<$sock>) {
        if (/^PING(.*)$/i) {
            send( $sock, "PONG $1\r\n", 0 );
            return;
        }
        else {
            return $_;
        }
    }
}

sub write {
    my $self = shift;
    my $sock = $self->{sock};
    send( $sock, $_[0], 0 );
}

sub get_nick {
    my $self = shift;
    return $self->{nick};
}
1;
