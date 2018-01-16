#!/bin/bash

DIR="$(cd "$(dirname "$0")" && pwd)"

if [ -n "$1" ]; then
    TerarkTemp=$1
else
    if [ ! -f $DIR/my.cnf ]; then
        echo file "$DIR/my.cnf" does not exist
        exit 1
    fi
    TerarkTemp=`sed -n 's/^\s*datadir\s*=\s*\(.*\)/\1/p' $DIR/my.cnf`
    if [ -z "$TerarkTemp" ]; then
        echo datadir is not defined in config file: $DIR/my.cnf
        exit 1
    fi
    if [ "`basename $TerarkTemp`" = data ]; then
        TerarkTemp=$(cd $(dirname $TerarkTemp);pwd)/terark-temp
    fi
fi
if [ ! -d "$TerarkTemp" ]; then
    echo TerarkTemp = "$TerarkTemp" does not exit or is not a directory
    exit 1
fi

env TerarkZipTable_localTempDir=$TerarkTemp \
    TerarkZipTable_keyPrefixLen=4 \
    TerarkZipTable_oldOffsetOf=0 \
    TerarkZipTable_enable_partial_remove=1 \
    TerarkZipTable_offsetArrayBlockUnits=128 \
    TerarkZipTable_indexCacheRatio=0.001 \
    TerarkZipTable_sampleRatio=0.02 \
    TerarkZipTable_extendedConfigFile=$DIR/license \
    TerarkZipTable_write_buffer_size=2G \
    TerarkZipTable_target_file_size_base=10G \
    TerarkZipTable_level0_file_num_compaction_trigger=5 \
    TerarkZipTable_level0_slowdown_writes_trigger=30 \
    TerarkZipTable_level0_stop_writes_trigger=60 \
    TerarkZipTable_max_subcompactions=2 \
    TerarkUseDivSufSort=1 \
    $DIR/support-files/mysql.server start \
        --defaults-file=$DIR/my.cnf \
        --character-sets-dir=$DIR/share/charsets \
        --lc-messages_dir=$DIR/share \
        --plugin-dir=$DIR/lib/plugin \
    

#$DIR/support-files/mysql.server start --defaults-file=$DIR/my.cnf
#gdb --args $DIR/bin/mysqld --defaults-file=$DIR/my.cnf 

