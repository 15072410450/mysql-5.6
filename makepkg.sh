
mydir=$(cd $(dirname $0);pwd)
make install
sh $mydir/post-make-install.sh
mv __MYSQL_INSTALL_DIR__ terark-mysql
tar czf terark-mysql.tgz terark-mysql

