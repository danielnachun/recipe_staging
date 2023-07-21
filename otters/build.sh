#!/bin/bash 

install -Dd ${PREFIX}/bin ${PREFIX}/libexec/otters
cp -r PRSmodels ${PREFIX}/libexec/otters
rm -rf ${PREFIX}/libexec/otters/PRSmodels/__pycache__
cp -r *.py ${PREFIX}/libexec/otters
chmod +x ${PREFIX}/libexec/otters/imputing.py
chmod +x ${PREFIX}/libexec/otters/testing.py
chmod +x ${PREFIX}/libexec/otters/training.py
ln -sf ${PREFIX}/libexec/otters/imputing.py ${PREFIX}/bin/imputing
ln -sf ${PREFIX}/libexec/otters/testing.py ${PREFIX}/bin/testing
ln -sf ${PREFIX}/libexec/otters/training.py ${PREFIX}/bin/training
