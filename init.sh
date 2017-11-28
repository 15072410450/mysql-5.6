#/bin/bash

DIR="$(cd "$(dirname "$0")" && pwd)"

if [ "$1" = "prepare" ]; then
    if [ -z "$2" ]; then
        sed -i "s:/usr/local/mysql-on-terarkdb-4.8-bmi2-0:$DIR:g" support-files/mysql.server
        sed -i "s:/usr/local/mysql-on-terarkdb-4.8-bmi2-0:$DIR:g" bin/mysqld_safe
        sed -i "s:/usr/local/mysql-on-terarkdb-4.8-bmi2-0:$DIR:g" my.cnf
        sed -i "s:/usr/local/mysql-on-terarkdb-4.8-bmi2-0:$DIR:g" start.sh
        echo "done"
    else
        sed -i "s:/usr/local/mysql-on-terarkdb-4.8-bmi2-0:$2:g" support-files/mysql.server
        sed -i "s:/usr/local/mysql-on-terarkdb-4.8-bmi2-0:$2:g" bin/mysqld_safe
        sed -i "s:/usr/local/mysql-on-terarkdb-4.8-bmi2-0:$2:g" my.cnf
        sed -i "s:/usr/local/mysql-on-terarkdb-4.8-bmi2-0:$2:g" start.sh
        echo "done"
    fi
elif [ "$1" = "init" ]; then
    echo "start initializing..."
    $DIR/scripts/mysql_install_db \
	--defaults-file=$DIR/my.cnf
    echo "done"
else
    echo "usage: ./init.sh prepare|init"
fi

