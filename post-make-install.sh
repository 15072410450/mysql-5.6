#/bin/bash

CodeDir=$(cd $(dirname $0) && pwd)
BuildDir=$PWD

for file in `cat $CodeDir/substitue_file_list.txt`
do
	sed -i "s:$BuildDir/__MYSQL_INSTALL_DIR__:__MYSQL_INSTALL_DIR__:g" $BuildDir/__MYSQL_INSTALL_DIR__/$file
done

cp $CodeDir/substitue_file_list.txt __MYSQL_INSTALL_DIR__
cp $CodeDir/my.cnf-terark-template  __MYSQL_INSTALL_DIR__/my.cnf
cp $CodeDir/init.sh                 __MYSQL_INSTALL_DIR__
cp $CodeDir/start*.sh               __MYSQL_INSTALL_DIR__
