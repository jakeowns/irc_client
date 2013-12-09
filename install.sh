#!/bin/bash
if [[ $UID != 0 ]]
then
	echo "This script requires root or sudo to run!";
	exit 1;
else
	apt-get update
	apt-get install libx11-dev
	cpan App::cpanminus;
	cpan local::lib;
fi
#install dependencies into ./local
cpanm -L local --installdeps .;
