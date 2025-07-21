# Snakefile for FCS pipeline with channel selection

import os
import glob

# Define main directories for raw input, processed outputs, and plots
RAW_DIR        = "data/raw"
PROCESSED_DIR  = "data/processed"
PLOT_DIR       = "plots"

# Discover all sample base names (without extension) in RAW_DIR
samples = [
    os.path.splitext(os.path.basename(f))[0]
    for f in glob.glob(os.path.join(RAW_DIR, "*.fcs"))
]

# Master rule: build all processed .fcs files and plots for all samples
rule all:
    input:
        expand(os.path.join(PROCESSED_DIR, "{sample}_umap_clust.fcs"), sample=samples),
        expand(os.path.join(PLOT_DIR, "{sample}.png"), sample=samples)

# Main processing rule: takes one FCS file, makes a processed FCS and plot
rule process_fcs:
    input:
        fcs = os.path.join(RAW_DIR, "{sample}.fcs")
    output:
        fcs  = os.path.join(PROCESSED_DIR, "{sample}_umap_clust.fcs"),
        plot = os.path.join(PLOT_DIR,       "{sample}.png")
    params:
        # Always look for 'channels.txt' at the project root; optional
        channels = "channels.txt"
    shell:
        r"""
        # If channels.txt exists, pass it as an argument, else skip
        extra=""
        if [ -f {params.channels} ]; then
            extra="--channels {params.channels}"
        fi

        # Run the R processing script with required arguments, passing channels if present
        Rscript scripts/process_fcs.R \
          -i "{input.fcs}" \
          -o "{output.fcs}" \
          -p "{output.plot}" \
          $extra
        """