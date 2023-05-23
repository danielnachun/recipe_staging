#!/usr/bin/env bash

install -Dm 755 "${SRC_DIR}/code/DaPars_Extract_Anno.py" "${PREFIX}/bin/DaPars_Extract_Anno.py"
install -Dm 755 "${SRC_DIR}/code/Dapars2_Multi_Sample.py" "${PREFIX}/bin/Dapars2_Multi_Sample.py"
install -Dm 755 "${SRC_DIR}/code/gtf2bed12.py" "${PREFIX}/bin/gtf2bed12.py"
