#!/bin/bash

function cpan_install() {
	perl -M$1 -e 1 > /dev/null 2>&1
	if [ $? -ne 0 ]
	then
		cpan install $1
	else
		echo "$1 already installed"
	fi
}

if [[ $UID != 0 ]]
then
	echo "This script requires root or sudo to run!"
	exit 1
fi

cpan_install "Tk"
cpan_install "Tk::DynaTabFrame"
cpan_install "Switch"
cpan_install "Switch::Plain"
