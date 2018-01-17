
COMPILER=`sh ../../terark/get-compiler-name.sh`
if [ -z "$COMPILER" ]; then
	echo COMPILER is empty 1>&2
	exit
fi
if [ -z "$BMI2" ]; then
	BMI2=`sh ../../terark/cpu_has_bmi2.sh`
fi
ln -sf ../../terark-zip-rocksdb/pkg/terark-zip-rocksdb-Linux-x86_64-${COMPILER}-bmi2-${BMI2} terark-zip-rocksdb-pkg
ln -sf ../../snappy/package-dir snappy-pkg
btype=MinSizeRel
btype=Release
btype=RelWithDebInfo
IGNORE_AIO_CHECK=0
#btype=Debug
cmake .. \
 -DCMAKE_VERBOSE_MAKEFILE=ON \
 -DCMAKE_SKIP_BUILD_RPATH=ON \
 -DCMAKE_SKIP_INSTALL_RPATH=ON \
 -DCMAKE_BUILD_TYPE=$btype \
 -DDISABLE_SHARED=1 \
 -DIGNORE_AIO_CHECK=$IGNORE_AIO_CHECK \
 -DWITH_SSL=system \
 -DWITH_ZLIB=bundled \
 -DWITH_SNAPPY=${PWD}/snappy-pkg \
 -DWITH_TERARKDB=${PWD}/terark-zip-rocksdb-pkg \
 -DMYSQL_MAINTAINER_MODE=0 \
 -DENABLED_LOCAL_INFILE=1 \
 -DENABLE_DTRACE=0 \
 -DCMAKE_CXX_FLAGS_RELWITHDEBINFO="-march=native -DNDEBUG=1 -I../../boost-pkg" \
 -DCMAKE_INSTALL_PREFIX=__MYSQL_INSTALL_DIR__

if [ "$IGNORE_AIO_CHECK" -eq 1 ]; then
	echo NOTE: IGNORE_AIO_CHECK = $IGNORE_AIO_CHECK
fi
