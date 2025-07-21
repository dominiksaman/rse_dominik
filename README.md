# FCS CyTOF Pipeline

## Overview

- **Purpose:** Fast, reproducible UMAP+KMeans clustering and plotting for FCS files (e.g. CyTOF).
- **Features:** 
  - Channel selection via `channels.txt` (optional).
  - Dockerised: runs identically anywhere.
  - Snakemake-powered for parallel sample processing.

## Usage

## 1. Run via Docker (recommended, fastest)

# Get code and test data:
```
git clone --branch final https://github.com/dominiksaman/rse_dominik.git
cd rse_dominik
```

# (Option 1, preferred) Pull pre-built image:
```
docker pull dominiksaman/fcs_pipeline:latest
```

# Run the pipeline
```
docker run --rm -v $(pwd):/pipeline -w /pipeline dominiksaman/fcs_pipeline:latest --cores 4
```

# (Option 2, if you want to build yourself)
```
# docker build -t fcs_pipeline .
# docker run --rm -v $(pwd):/pipeline -w /pipeline fcs_pipeline --cores 4m -v $(pwd):/pipeline -w /pipeline fcs_pipeline --cores 4
```

### 2. **Manual conda installation**

# Clone the repository (if not already)
```
git clone --branch final https://github.com/dominiksaman/rse_dominik.git
cd rse_dominik
```


# Set up conda environment and run
```
conda env create -f environment.yml
conda activate fcs_pipeline
snakemake --cores 4
```

### 3.  **Input and Output**

> Put your .fcs files in data/raw/
> Output FCS with UMAP+Cluster columns: data/processed/
> Output plots: plots/

### 4. **Optional: Custom Channel Selection**
> Place a channels.txt in repo root. It must be a tab-separated file, with columns:
name    desc    range    minRange    maxRange    use
> Channels with use==1 are included in the analysis.
> If omitted, fallback is all non-scatter, non-NA channel

### 5. **Optional: if you want to run individual processing scripts**
```
Rscript scripts/process_fcs.R -i <input.fcs> -o <output.fcs> -p <plot.png> [-c channels.txt]
```



