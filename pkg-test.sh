
set -x
set -e
rm -rf __MYSQL_INSTALL_DIR__
rm -rf packageRoot
rm -rf databaseDir
make install -j8
sh -x ../post-make-install.sh
mv __MYSQL_INSTALL_DIR__ packageRoot
sh -x packageRoot/init.sh prepare databaseDir
sh -x packageRoot/init.sh init
sh -x packageRoot/start.sh

