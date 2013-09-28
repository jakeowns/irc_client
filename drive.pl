#!/usr/bin/perl
use strict;
use warnings;
use lib '/home/Jake/perl';
use IRC;
my$client = IRC->new;
$client->start_conn;
print $client->rec_in while 1;
