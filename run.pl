#!/usr/bin/perl
use strict;
use warnings;
use FindBin qw($Bin);
use lib "$Bin/lib";
use local::lib "$Bin/local";
use IRC::GUI;
IRC::GUI->run();