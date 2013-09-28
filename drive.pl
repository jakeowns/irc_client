#!/usr/bin/perl
use strict;
use warnings;
#use lib '/home/Jake/perl';
use IRC;
my $client = IRC->new;
$client->connect;
$client->login;

#$client->Login;
die "cant fork: $!" unless defined( my $kidpid = fork() );
if ($kidpid) {
    print $client->get_in while 1;
    kill 15, $kidpid;
}
else {
    while ( defined( my $str = <stdin> ) ) {
        $client->msg("$str\r\n");
    }
}
exit 0;
__END__
