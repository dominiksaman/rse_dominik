#!/usr/bin/env bash
set -e
echo "Installing flowCore from Bioconductor..."
"${PREFIX}/bin/Rscript" -e "if (!requireNamespace('BiocManager', quietly=TRUE)) install.packages('BiocManager', repos='https://cloud.r-project.org'); BiocManager::install('flowCore', ask=FALSE, update=FALSE)"