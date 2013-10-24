use strict;
use warnings;

package IRC;
use Socket qw(pack_sockaddr_in inet_aton);

sub new {
    my ( $class, $args ) = @_;
    my $self = bless {}, $class;
    return $self->_init($args);
}

sub DESTROY {
    my $self = shift;
    close( $self->{_sock} ) if $self->{_sock};
}

sub _init {
    my ( $self, $args ) = @_;
    $self->{_sock}   = $args->{sock}    || die "no socket: $!";
    $self->{_server} = $args->{server}  || "irc.freenode.net";
    $self->{_port}   = $args->{port}    || 6667;
    $self->{_channel} = $args->{channel} || [];
    $self->{_nick}   = $args->{nick}
      || join( '', map { ( "a" .. "z" )[ rand 26 ] } 1 .. 8 );
    return $self;
}

sub connect {
    my $self = shift;
    connect( $self->{_sock},
        pack_sockaddr_in( $self->{_port}, inet_aton( $self->{_server} ) ) )
      or die "connect: $!";
    $self->login;
}

sub login {
    my $self = shift;
    my $sock = $self->{_sock};
    send( $sock, "NICK $self->{_nick}\r\n", 0 );
    send( $sock, "USER $self->{_nick} 8 * $self->{_nick}\r\n", 0 );
}

sub join_chan {
    my $self = shift;
    my $sock = $self->{_sock};
    foreach my $chan ( @{ $self->{_channel} } ) {
        send( $sock, "JOIN $chan\r\n", 0 );
    }

}

sub read {
    my $self = shift;
    my $sock = $self->{_sock};
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
    my $sock = $self->{_sock};
    send( $sock, $_[0], 0 );
}

sub get_nick {
    my $self = shift;
    return $self->{_nick};
}
1;
