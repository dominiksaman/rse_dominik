# Use Miniconda as base
FROM continuumio/miniconda3

# Set working directory inside container
WORKDIR /pipeline

# Copy environment config and create conda environment (named fcs_pipeline)
COPY environment.yml environment.yml
RUN conda env create -f environment.yml

# Optional: Add post-link hook for bioconductor-flowcore on ARM
COPY conda-hooks/post-link.sh /opt/conda/envs/fcs_pipeline/etc/conda/post-link.d/flowcore_install.sh

# Activate environment by default for all RUN/CMD/ENTRYPOINT
SHELL ["/bin/bash", "-c"]
ENV PATH=/opt/conda/envs/fcs_pipeline/bin:$PATH

# Copy source code and pipeline into container
COPY . /pipeline

# Make sure expected folders exist
RUN mkdir -p data/raw data/processed plots

# Default command: show snakemake help (so container doesn't error if run without args)
ENTRYPOINT ["/opt/conda/envs/fcs_pipeline/bin/snakemake"]
CMD ["--help"]