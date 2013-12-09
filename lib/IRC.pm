package IRC;
use strict;
use warnings;
use Moose;
use Socket qw(pack_sockaddr_in inet_aton PF_INET SOCK_STREAM);

has 'sock' => (
    is       => 'ro',
    builder  => '_build_sock',
    required => 1,
);
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

sub _build_sock {
    socket( my $sock, PF_INET, SOCK_STREAM, 0 )
      or die "socket: $!";
    return $sock;
}

sub connect {
    my $self = shift;
    my $addr = $self->{server};
    unless($addr =~ /^(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})$/) {
        $addr = inet_aton( $addr );
    }
    connect( $self->{sock},
        pack_sockaddr_in( $self->{port}, $addr ) ) )
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
    my $line;
    my $stat = sysread( $sock, $line, 10240 );
    return unless ( defined $stat );
    $_ = $line;
    if (/^PING(.*)$/i) {
        $self->write("PONG $1\r\n");
        return;
    }
    else {
        return $_;
    }
}

sub write {
    my $self = shift;
    my $sock = $self->{sock};
    send( $sock, $_[0], 0 );
}
1;
