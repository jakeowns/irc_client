package IRC;
use IO::Socket;
use Socket qw(PF_INET SOCK_STREAM pack_sockaddr_in inet_aton);
use strict;
use warnings;
sub new {
	my($class, @args) = @_;
	my$self = bless {}, $class;
	return $self->_init(@args);
}
#instance variables
#+server
#+port
#+nickname
sub _init {
	my$self = shift;
	$self->{_server} = shift || "irc.freenode.net";
	$self->{_port} = shift || 6667;
	$self->{_nick} = shift || "meh";
	socket(my $sock, PF_INET, SOCK_STREAM, 0)
     or die "socket: $!";
	$self->{_sock} = $sock;
	return $self;
}
sub start_conn {
	my$self = shift;
	connect($self->{_sock}, pack_sockaddr_in($self->{_port}, inet_aton($self->{_server})))
     or die "connect: $!";
	login();
}
sub login {
	my$self = shift;
	fh = $self->{_sock};
	my($nick, $user, $chan) = ("NICK $self->{_nick}\r\n", "USER $self->{_nick} 8 * $self->{_nick}\r\n", "JOIN #linux\r\n");
	send(fh, $nick);
	send(fh, $user);
	send(fh, $chan);
}
sub rec_in {
	my$self = shift;
	my$fh = $self->{_sock};
	while(<$fh>) {
		return $_;
	}
}
1;
