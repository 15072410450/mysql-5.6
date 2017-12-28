#/bin/bash

PackageDir=$(cd $(dirname $0) && pwd)

if [ "$1" = "prepare" ]; then
    if [ -z "$2" ]; then
		DataBaseDir=$PackageDir
	else
		mkdir -p $2
		DataBaseDir=`cd $2 && pwd`
	fi
	mkdir -p $DataBaseDir/terark-temp
	mkdir -p $DataBaseDir/data
	mkdir -p $DataBaseDir/log
	for file in `cat $PackageDir/substitue_file_list.txt` my.cnf;
	do
        sed -e "s:__MYSQL_INSTALL_DIR__/data:$DataBaseDir/data:g" \
			-e "s:__MYSQL_INSTALL_DIR__/log:$DataBaseDir/log:g" \
			-e "s:__MYSQL_INSTALL_DIR__:$PackageDir:g" \
			-i $PackageDir/$file
	done
elif [ "$1" = "init" ]; then
    echo "start initializing..."
	cd $PackageDir # mysql_install_db bug, must cd to this dir
    $PackageDir/scripts/mysql_install_db --defaults-file=$PackageDir/my.cnf
    echo "done"
else
    echo "usage: ./init.sh prepare [DataBaseDir] | init"
fi

