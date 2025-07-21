# FCS CyTOF Pipeline

## Overview

- **Purpose:** Fast, reproducible UMAP+KMeans clustering and plotting for FCS files (e.g. CyTOF).
- **Features:** 
  - Channel selection via `channels.txt` (optional).
  - Dockerised: runs identically anywhere.
  - Snakemake-powered for parallel sample processing.

## Usage

### 1. **Install via Docker** (recommended)

```bash
git clone https://github.com/<yourusername>/rse_docker.git
cd rse_docker
docker build -t fcs_pipeline .
# Run pipeline (mount local dir as /pipeline)
docker run --rm -v $(pwd):/pipeline -w /pipeline fcs_pipeline --cores 4
```

### 2. **Manual conda installation**

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



