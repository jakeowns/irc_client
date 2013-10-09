package IRC;
use Socket qw(PF_INET SOCK_STREAM pack_sockaddr_in inet_aton);
use strict;
use warnings;

sub new {
    my ( $class, @args ) = @_;
    my $self = bless {}, $class;
    return $self->_init(@args);
}

sub DESTROY {
    my $self = shift;
    close( $self->{_sock} ) if $self->{_sock};
}

sub _init {
    my $self = shift;
		$self->{_sock} = shift or die "no socket: $!";
    $self->{_server} = shift || "irc.freenode.net";
    $self->{_port}   = shift || 6667;
    $self->{_nick}   = shift || "Guest123124";
    return $self;
}

sub connect {
    my $self = shift;
    connect( $self->{_sock},
        pack_sockaddr_in( $self->{_port}, inet_aton( $self->{_server} ) ) )
      or die "connect: $!";
}

sub login {
    my $self = shift;
    my $sock = $self->{_sock};
    send( $sock, "NICK $self->{_nick}\r\n",                    0 );
    send( $sock, "USER $self->{_nick} 8 * $self->{_nick}\r\n", 0 );
    send( $sock, "JOIN #linux\r\n",                            0 );
}

sub read {
    my $self = shift;
    my $sock = $self->{_sock};
    while (<$sock>) {
        if (/^PING(.*)$/i) {
            send( $sock, "PONG $1\r\n", 0 );
        }
        else {
            return $_;
        }
    }
}

sub write {
    my $self = shift;
    my $sock = $self->{_sock};
    send( $sock, $_[0], 0 );
}
1;
