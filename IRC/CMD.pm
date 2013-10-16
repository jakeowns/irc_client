package IRC::CMD;
use strict;
use warnings;
use Switch::Plain;

sub get {
    my $class = shift;
    $_ = shift;
    m/^(.+) (.*)/;
    my ( $cmd, $arg ) = ( $1, $2 );
    $cmd =~ tr!A-Z!a-z!;
    sswitch($cmd) {
        case 'j' : { "join $arg"; }
        case 'q' : { "quit"; }
	case 'k' : { "kick $arg"; }
	case 'a' : { "away"; }
	case 'cpm' : { "cprivmsg $arg"; }
	case 'h' : { "help"; }
	case 'i' : { "invite $arg"; }
	case 'l' : { "list $arg"; }
	case 'm' : { "mode $arg"; }
	case 'n' : { "nick $arg"; }
	case 'nt' : { "notice $arg"; }
	case 'op' : { "oper $arg"; }
	case 'pm' : { "privmsg $arg"; }
	case 'w' : { "who $arg"; }
	case 'wi' : { "whois $arg"; }
	case 'ww' : { "whowas $arg"; }
	case 'v' : { "version"; }
	case 'u' : { "user $arg"; }
	case 'tr' : { "trace $arg"; }
	case 't' : { "time"; }
	case 'su' : { "summon $arg"; }
	case 'sn' : { "setname $arg"; }
	case 'sq' : { "squit $arg"; }
	case 'si' : { "silence $arg"; }
	case 's' : { "stats $arg"; }
	case 'rh' : { "rehash"; }
	case 'r' : { "rules"; }
	case 'md' : { "motd $arg"; }
	case 'e' : { "error $arg"; }
        default  : {
            ( defined $arg ) ? "$cmd $arg" : "$cmd";
        }
    };
}
1;
__END__
