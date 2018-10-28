#!/bin/bash

if [[ -z $1 ]]; then
	echo "error, must have either pkgmgr or srvmgr"
	exit;
elif [ $1 == "pkgmgr" ]; then
	for i in apt-get yum brew; do
		if [ -x "$(which $i)" ];  then
			case $i in
				apt-get)
					echo "sudo apt-get -y"
					;;
				yum)
					echo "sudo yum -y"
					;;
				brew)
					echo "brew"
					;;
			esac
		fi
	done
elif [ $1 == 'srvmgr' ]; then
	for j in services systemctl brew; do
		if [ -x "$(which $j)" ]; then
			if [ $j == "brew" ]; then
				echo "brew services"
			else
				echo $j
			fi
		fi
	done
fi

