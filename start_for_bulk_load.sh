#!/bin/bash

DIR="$(cd $(dirname $0);pwd)"

MemTable=8G # **Large, for bulk load only**

env TerarkZipTable_localTempDir=/ssd/mysql/terark-temp \
    TerarkZipTable_keyPrefixLen=4 \
    TerarkZipTable_offsetArrayBlockUnits=128 \
	TerarkZipTable_base_background_compactions=1 \
	TerarkZipTable_max_background_compactions=1 \
	TerarkZipTable_max_subcompactions=4 \
	TerarkZipTable_min_merge_width=1000 \
	TerarkZipTable_max_merge_width=2000 \
	TerarkZipTable_level0_file_num_compaction_trigger=1000 \
    TerarkZipTable_softZipWorkingMemLimit=32G \
    TerarkZipTable_hardZipWorkingMemLimit=48G \
    TerarkZipTable_write_buffer_size=$MemTable \
    TerarkZipTable_target_file_size_base=48G \
    TerarkZipTable_indexCacheRatio=0.001 \
    TerarkZipTable_sampleRatio=0.015 \
    TerarkZipTable_extendedConfigFile=$DIR/license \
    $DIR/support-files/mysql.server start --defaults-file=$DIR/my.cnf
