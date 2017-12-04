#!/bin/bash

DIR="$(cd "$(dirname "$0")" && pwd)"

env TerarkZipTable_localTempDir=$DIR/terark-temp \
    TerarkZipTable_keyPrefixLen=4 \
    TerarkZipTable_offsetArrayBlockUnits=128 \
    TerarkZipTable_indexCacheRatio=0.001 \
    TerarkZipTable_extendedConfigFile=$DIR/license \
    TerarkUseDivSufSort=1 \
    $DIR/support-files/mysql.server start --defaults-file=$DIR/my.cnf
