编译基于静态库ssl的可执行文件，步骤如下

0. 下载一个1.0.1e版本的ssl，编译一份静态库出来，mkdir一个lib, 放到lib里;
1. storage/rocksdb/CMakeList.txt 里涉及到terark的，将so改为static, 以及增加libcrypto.a和-ldl

```
# terocks
IF (NOT "$ENV{WITH_TERARKDB}" STREQUAL "")
  SET(rocksdb_static_libs ${rocksdb_static_libs}
  -Wl,--whole-archive
  $ENV{WITH_TERARKDB}/lib_static/libterark-zip-rocksdb-r.a
  $ENV{WITH_TERARKDB}/lib_static/libterark-zbs-r.a
  $ENV{WITH_TERARKDB}/lib_static/libterark-fsa-r.a
  $ENV{WITH_TERARKDB}/lib_static/libterark-core-r.a
  -Wl,--no-whole-archive
  /newssd1/temp/openssl-1.0.1e/lib/libcrypto.a
  ${CMAKE_SOURCE_DIR}/build/storage/rocksdb/librocksdb_se.a
  -ldivsufsort-r
  -ldl
  -lgomp -lz)
ENDIF()
```

2. cmake/libutils.cmake里, IF(NOT DISABLE_SHARED) 之前加上 SET(DISABLE_SHARED 1);
3. libmysql/CMakeLists.txt里, IF(NOT DISABLE_SHARED) 之前加上 SET(DISABLE_SHARED 1);
4. 编译选项，注意WITH_SSL和CMAKE_INSTALL_PREFIX

```
	nohup cmake .. -DCMAKE_BUILD_TYPE=RelWithDebInfo \
			-DWITH_SSL="/newssd1/temp/openssl-1.0.1e" \
    		-DWITH_ZLIB=bundled -DMYSQL_MAINTAINER_MODE=0 \
         	-DENABLED_LOCAL_INFILE=1 -DENABLE_DTRACE=0 \
         	-DCMAKE_CXX_FLAGS="-march=native" \
         	-DCMAKE_INSTALL_PREFIX=/newssd1/temp/mysql-on-terarkdb &
```
5. 修改启动脚本support-files/mysql.server

```
basedir=`pwd`
datadir_set=1
$bindir/mysqld_safe $other_args --basedir="$basedir" --datadir="$datadir" --pid-file="$mysqld_pid_file_path" >/dev/null &
```

6. 修改参数初始化步骤, 在注释#First之后

```
#
# First, try to find BASEDIR and ledir (where mysqld is)
#
parse_arguments PICK-ARGS-FROM-ARGV "$@"
```
