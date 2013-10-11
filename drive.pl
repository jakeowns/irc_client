#!/usr/bin/perl
use strict;
use warnings;
use IRC;
use Socket qw(PF_INET SOCK_STREAM);
use IO::Select;
socket( my $sock, PF_INET, SOCK_STREAM, 0 )
  or die "socket: $!";
my $nick = join( '', map { ( "a" .. "z" )[ rand 26 ] } 1 .. 8 );
my $client = IRC->new( $sock, "irc.freenode.net", 6667, $nick );
$client->connect;
$client->login;

my $sel = IO::Select->new;
$sel->add($sock);
$sel->add( \*STDIN );
while ( my @ready = $sel->can_read ) {
    foreach my $fh (@ready) {
        if ( $fh == $sock ) {
            print $client->read;
        }
        else {
            $client->write( <stdin> . "\r\n" );
        }
    }
}
exit 0;
__END__
