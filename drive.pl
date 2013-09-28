#!/usr/bin/perl
use strict;
use warnings;
use IRC;
my $client = IRC->new;
$client->connect;
$client->login;

die "cant fork: $!" unless defined( my $kidpid = fork() );
if ($kidpid) {
    print $client->read while 1;
    kill 15, $kidpid;
}
else {
    while ( defined( my $str = <stdin> ) ) {
        $client->write("$str\r\n");
    }
}
exit 0;
__END__
