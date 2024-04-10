#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

rm -rf sources/ext
sed -i 's/double_t/Double_t/g; s/int_t/Int_t/g; s/bool_t/Bool_t/g' sources/plinkseq/sources/lib/matrix.proto
protobuf --proto_path=sources/plinkseq/sources/lib --cpp_out=sources/plinkseq/sources/lib
mv sources/plinkseq/sources/lib/matrix.pb.cc sources/plinkseq/sources/lib/matrix.pb.cpp
mv sources/plinkseq/sources/lib/variant.pb.cc sources/plinkseq/sources/lib/variant.pb.cpp
#sed -i 's/double_t/Double_t/g; s/int_t/Int_t/g; s/bool_t/Bool_t/g' sources/plinkseq/sources/include/plinkseq/matrix.pb.h
#sed -i 's/double_t/Double_t/g; s/int_t/Int_t/g; s/bool_t/Bool_t/g' sources/plinkseq/sources/lib/matrix.pb.cpp
sed -i 's/double_t/Double_t/g' sources/plinkseq/sources/lib/matdb.cpp
sed -i 's/( i_hi < 0 )/( *i_hi < 0 )/' sources/plinkseq/sources/lib/r8lib.cpp
sed -i 's/$(PROTOBUF_LIB_FULL_PATH)//g' Makefile
sed -i 's/-lz/-lprotobuf -labsl_log_internal_message -labsl_log_internal_check_op -lz /g' Makefile
make CXX="${CXX}" CXXFLAGS="${CXXFLAGS} -Wno-register" STATIC_FLAG="${LDFLAGS}"

mkdir -p ${PREFIX}/bin
install -m 755 build/execs/behead ${PREFIX}/bin
install -m 755 build/execs/browser ${PREFIX}/bin
install -m 755 build/execs/gcol ${PREFIX}/bin
install -m 755 build/execs/mm ${PREFIX}/bin
install -m 755 build/execs/mongoose ${PREFIX}/bin
install -m 755 build/execs/pdas ${PREFIX}/bin
install -m 755 build/execs/pseq ${PREFIX}/bin
install -m 755 build/execs/smp ${PREFIX}/bin
install -m 755 build/execs/tab2vcf ${PREFIX}/bin
