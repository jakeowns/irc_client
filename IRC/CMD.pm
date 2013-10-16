package IRC::CMD;
use strict;
use warnings;
use Switch::Plain;
#use feature qw(say);
sub get {
	my$class = shift;
	$_ = shift;
	s!^(.+) (.*)!!;
	my( $cmd, $arg) = ($1 , $2);
	$cmd =~ tr!A-Z!a-z!;
	sswitch($cmd) {
		case 'j' :{ "join $arg"; }
		case 'q' :{ "quit"; }
		default: {
			(defined $arg)?"$cmd $arg":"$cmd";
		}
	}
}
1;
__END__
sub new {
	my($class, @args) = @_;
	my $self = {};
	return bless $self, $class;
}
