ln -s ~/osc/terark-zip-rocksdb/pkg/terark-zip-rocksdb-Linux-x86_64-g++-4.8-bmi2-1 terark-zip-rocksdb-pkg
btype=MinSizeRel
btype=Release
btype=RelWithDebInfo
#btype=Debug
cmake .. \
 -DCMAKE_VERBOSE_MAKEFILE=ON \
 -DCMAKE_SKIP_BUILD_RPATH=ON \
 -DCMAKE_SKIP_INSTALL_RPATH=ON \
 -DCMAKE_BUILD_TYPE=$btype \
 -DDISABLE_SHARED=1 \
 -DWITH_SSL=system \
 -DWITH_ZLIB=bundled \
 -DWITH_SNAPPY=/opt/gcc-4.8 \
 -DWITH_TERARKDB=${PWD}/terark-zip-rocksdb-pkg \
 -DMYSQL_MAINTAINER_MODE=0 \
 -DENABLED_LOCAL_INFILE=1 \
 -DENABLE_DTRACE=0 \
 -DCMAKE_CXX_FLAGS="-march=native" \
 -DCMAKE_INSTALL_PREFIX=__MYSQL_INSTALL_DIR__
