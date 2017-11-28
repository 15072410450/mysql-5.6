#!/bin/bash

DIR="$(cd "$( dirname "$0")" && pwd)"

env TerarkZipTable_localTempDir=/usr/local/mysql-on-terarkdb-4.8-bmi2-0/terark-temp \
    TerarkZipTable_keyPrefixLen=4 \
    TerarkZipTable_offsetArrayBlockUnits=128 \
    TerarkZipTable_indexCacheRatio=0.001 \
    TerarkZipTable_extendedConfigFile=$DIR/license \
    support-files/mysql.server start --defaults-file=$DIR/my.cnf
