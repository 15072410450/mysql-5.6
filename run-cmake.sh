
COMPILER=`sh ../../terark/get-compiler-name.sh`
if [ -z "$COMPILER" ]; then
	echo COMPILER is empty 1>&2
	exit
fi
DIR="$(cd "$(dirname "$0")" && pwd)"
BMI2=`sed '/^BMI2=/!d;s/.*=//' $DIR/../make.config`
ln -sf ../../terark-zip-rocksdb/pkg/terark-zip-rocksdb-Linux-x86_64-${COMPILER}-bmi2-${BMI2} terark-zip-rocksdb-pkg
ln -sf ../../snappy/package-dir snappy-pkg
btype=MinSizeRel
btype=Release
btype=RelWithDebInfo
IGNORE_AIO_CHECK=0
#btype=Debug
#WITH_SSL=/home/opt/gcc-4.8.2.bpkg-r2/gcc-4.8.2.bpkg-r2/
#WITH_SSL=system
WITH_SSL=/disk1/openssl-1.0.1e
WITH_UNIT_TEST=0
#CXX_FLAGS="-march=native -DNDEBUG=1 -I../../boost-pkg"
#CXX_FLAGS="-DNDEBUG=1 -I../../boost-pkg"
cmake .. \
 -DCMAKE_VERBOSE_MAKEFILE=ON \
 -DCMAKE_SKIP_BUILD_RPATH=ON \
 -DCMAKE_SKIP_INSTALL_RPATH=ON \
 -DCMAKE_BUILD_TYPE=$btype \
 -DDISABLE_SHARED=1 \
 -DIGNORE_AIO_CHECK=$IGNORE_AIO_CHECK \
 -DWITH_SSL=$WITH_SSL \
 -DWITH_ZLIB=bundled \
 -DWITH_SNAPPY=${PWD}/snappy-pkg \
 -DWITH_ZSTD=/usr/include \
 -DWITH_TERARKDB=${PWD}/terark-zip-rocksdb-pkg \
 -DMYSQL_MAINTAINER_MODE=0 \
 -DENABLED_LOCAL_INFILE=1 \
 -DWITH_UNIT_TEST=${WITH_UNIT_TEST} \
 -DENABLE_DTRACE=0 \
 -DCMAKE_CXX_FLAGS_RELWITHDEBINFO="-DNDEBUG=1 -I../../boost-pkg" \
 -DCMAKE_INSTALL_PREFIX=__MYSQL_INSTALL_DIR__

if [ "$IGNORE_AIO_CHECK" -eq 1 ]; then
	echo NOTE: IGNORE_AIO_CHECK = 1 1111111111111111111111111111111111111111111111
else
	echo INFO: IGNORE_AIO_CHECK = 0 0000000000000000000000000000000000000000000000
fi
if [ "$WITH_UNIT_TEST" -eq 1 ]; then
	echo INFO: WITH_UNIT_TEST = 1 1111111111111111111111111111111111111111111111
else
	echo NOTE: WITH_UNIT_TEST = 0 0000000000000000000000000000000000000000000000
fi
