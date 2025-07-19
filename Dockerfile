FROM continuumio/miniconda3

WORKDIR /pipeline
COPY environment.yml environment.yml
RUN conda env create -f environment.yml
# Install flowCore at build time (works on arm and x86):
COPY conda-hooks/post-link.sh /opt/conda/envs/fcs_pipeline/etc/conda/post-link.d/flowcore_install.sh

# Activate environment by default
SHELL ["/bin/bash", "-c"]
ENV PATH=/opt/conda/envs/fcs_pipeline/bin:$PATH

COPY . /pipeline

RUN mkdir -p data/raw data/processed plots

ENTRYPOINT ["/opt/conda/envs/fcs_pipeline/bin/snakemake"]
CMD ["--help"]