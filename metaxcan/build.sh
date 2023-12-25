#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

cd software
sed -i "s/'metax.deprecated'/'metax.deprecated', 'metax.cross_model', 'metax.expression', 'metax.genotype', 'metax.predixcan'/" setup.py
sed -i '1i #!/usr/bin/env/python3' PrediXcan.py
sed -i 's/Exceptions.ReportableException, e/Exceptions.ReportableException as e/' metax/MainScreen.py
${PYTHON} -m pip install . -vv --no-deps --no-build-isolation
install -m 755 BuildExpressionProduct.py ${PREFIX}/bin
install -m 755 CovarianceBuilder.py ${PREFIX}/bin
install -m 755 PrediXcanAssociation.py ${PREFIX}/bin
install -m 755 Predict.py ${PREFIX}/bin
