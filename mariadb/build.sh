#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

# TODO: add basedir to script
# sed -i "s|basedir"

cmake -S . -B build \
	-DMYSQL_DATADIR="${PREFIX}/var/mysql" \
	-DINSTALL_INCLUDEDIR=include/mysql \
	-DINSTALL_MANDIR=share/man \
	-DINSTALL_DOCDIR=share/doc/mariadb \
	-DINSTALL_INFODIR=share/info \
	-DINSTALL_MYSQLSHAREDIR=share/mysql \
	-DWITH_SSL=system \
	-DWITH_LIBFMT=system \
	-DWITH_UNIT_TESTS=OFF \
	-DDEFAULT_CHARSET=utf8mb4 \
	-DDEFAULT_COLLATION=utf8mb4_general_ci \
	-DINSTALL_SYSCONFDIR="${PREFIX}/etc" \
	-DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_VERBOSE_MAKEFILE=ON \
	-Wno-dev \
	-DBUILD_TESTING=OFF \
	${CMAKE_ARGS}
#
cmake --build build -- -j ${CPU_COUNT}
cmake --install build

rm -rf ${PREFIX}/mariadb-test
rm -rf ${PREFIX}/sql-bench
