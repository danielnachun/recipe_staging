#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

echo "packages:" > cabal.project
yq '(.packages)' stack.yaml | sed 's/- /  .\//' >> cabal.project

# sed -i 's/Prelude hiding (/Prelude hiding (unzip, /' unison-core/src/Unison/ABT.hs
# sed -i 's/Prelude hiding (/Prelude hiding (unzip, /' lib/unison-sqlite/src/Unison/Sqlite/Sql.hs
# sed -i 's/Prelude hiding (/Prelude hiding (unzip, /' unison-hashing-v2/src/Unison/Hashing/V2/ABT.hs
# sed -i 's/Prelude hiding (/Prelude hiding (unzip, /' lib/unison-pretty-printer/src/Unison/Util/Pretty.hs
# sed -i 's/Prelude hiding (/Prelude hiding (unzip, /' parser-typechecker/src/Unison/Runtime/ANF.hs
# sed -i 's/Prelude hiding (/Data.List hiding (unsnoc, /' parser-typechecker/src/Unison/Runtime/ANF.hs
# sed -i 's/Prelude hiding (/Prelude hiding (unzip, /' parser-typechecker/src/Unison/Codebase/SqliteCodebase/Migrations/MigrateSchema1To2.hs
# sed -i 's/import Prelude/import Prelude hiding (unzip)/' parser-typechecker/src/Unison/Runtime/ANF.hs
# sed -i 's/import Data.List/import Data.List hiding (unsnoc)/' parser-typechecker/src/Unison/Runtime/ANF.hs
# sed -i 's/as TLS/as TLS hiding (Ticket, HashAlgorithm)/' parser-typechecker/src/Unison/Runtime/Builtin.hs
# sed -i 's/Data.List hiding (/Data.List hiding (unzip, /' parser-typechecker/src/Unison/Syntax/TermPrinter.hs

export CABAL_DIR=${SRC_DIR}/.cabal
cabal v2-update
cabal v2-install unison-cli-main \
    --constraint "lsp<2.4" \
    --allow-newer=containers,text \
    --extra-lib-dirs=${PREFIX}/lib \
	--jobs=${CPU_COUNT} \
	--max-backjumps=100000 \
	--install-method=copy \
	--installdir=${PREFIX}/bin
cabal-plan license-report --licensedir=${SRC_DIR}/license-files exe:${PKG_NAME}
