#!/bin/bash
if [[ $UID != 0 ]]
then
	echo "This script requires root or sudo to run!";
	exit 1;
else
	cpan App::cpanminus;
fi
#install dependencies into ./local
cpanm -L local --installdeps .;
