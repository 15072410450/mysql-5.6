
COMPILER=`sh ../../terark/get-compiler-name.sh`
if [ -z "$BMI2" ]; then
	BMI2=`sh ../../terark/cpu_has_bmi2.sh`
fi
ln -s ../../terark-zip-rocksdb/pkg/terark-zip-rocksdb-Linux-x86_64-${COMPILER}-bmi2-${BMI2} terark-zip-rocksdb-pkg
ln -s ../../snappy/package-dir snappy-pkg
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
 -DWITH_SNAPPY=${PWD}/snappy-pkg \
 -DWITH_TERARKDB=${PWD}/terark-zip-rocksdb-pkg \
 -DMYSQL_MAINTAINER_MODE=0 \
 -DENABLED_LOCAL_INFILE=1 \
 -DENABLE_DTRACE=0 \
 -DCMAKE_CXX_FLAGS="-march=native -DNDEBUG=1" \
 -DCMAKE_INSTALL_PREFIX=__MYSQL_INSTALL_DIR__
