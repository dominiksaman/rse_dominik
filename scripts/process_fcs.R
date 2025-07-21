#!/usr/bin/env Rscript

#' Process FCS file: UMAP+KMeans, supports custom channel selection.
#'
#' Usage:
#'   Rscript process_fcs.R -i INPUT -o OUTPUT -p PLOT [-c CHANNELS]
#'
#' Options:
#'   -i, --input      Input FCS file path
#'   -o, --output     Output FCS file path (with UMAP+Cluster columns)
#'   -p, --plot       Output plot file (.png)
#'   -c, --channels   (optional) Path to channels.txt (tab-separated, must have 'name', 'desc', 'use')
#'
#' - If channels.txt is provided, only channels with use==1 are used for analysis.
#' - If not, fallback is: all non-NA desc, and not scatter channels (FSC/SSC).
#'
#' Author: Dominik Saman, July 2025

#  ---- Install needed libs ----

library(optparse)
library(flowCore)
library(ggplot2)
library(uwot)




# ---- Parse command-line options ----
option_list <- list(
  make_option(c("-i", "--input"), type="character", help="Input FCS file"),
  make_option(c("-o", "--output"), type="character", help="Output FCS file"),
  make_option(c("-p", "--plot"), type="character", help="Output plot file"),
  make_option(c("-c", "--channels"), type="character", default=NULL, help="Optional: channels.txt file")
)
opt <- parse_args(OptionParser(option_list=option_list))

if (is.null(opt$input) || is.null(opt$output) || is.null(opt$plot)) {
  stop("Input, output and plot must be provided")
}

# ---- Load FCS file ----
ff <- read.FCS(opt$input, transformation = FALSE)

# ---- Get parameter metadata (always a data.frame now) ----
par_df <- pData(parameters(ff))

# ---- Determine which channels to use ----
if (!is.null(opt$channels)) {
  # Read user-supplied channel inclusion table
  chan_tbl <- read.table(opt$channels, header=TRUE, sep="\t", quote="\"", stringsAsFactors=FALSE, strip.white=TRUE)
  stopifnot(all(c("name", "desc", "use") %in% names(chan_tbl)))
  # Whitespace-insensitive matching
  chan_tbl$name <- trimws(chan_tbl$name)
  chan_tbl$desc <- trimws(chan_tbl$desc)
  par_df$name <- trimws(par_df$name)
  par_df$desc <- trimws(par_df$desc)
  # Only rows where use==1
  selected <- subset(chan_tbl, use == 1)
  # Channels where BOTH name and desc match, and use==1 in the channels.txt
  keep_idx <- which(
    mapply(function(nm, ds) any(selected$name == nm & selected$desc == ds), par_df$name, par_df$desc)
  )
} else {
  # Fallback: all non-NA desc and not scatter (FSC, SSC)
  keep_idx <- which(!is.na(par_df$desc) & !grepl("^FSC|^SSC", par_df$desc, ignore.case=TRUE))
}

if (length(keep_idx) == 0) {
  stop("No analysis channels selected after filtering. Please check your channels.txt or FCS metadata.")
}

# ---- Build the expression matrix for selected channels ----
expr <- exprs(ff)[, keep_idx, drop=FALSE]
expr_trans <- asinh(expr / 5)  # Hyperbolic arcsin transform, standard for CyTOF

# ---- UMAP dimension reduction ----
umap_res <- umap(expr_trans, n_components=2)

# ---- KMeans clustering (5 clusters for now) ----
km <- kmeans(umap_res, centers=5)

# ---- Write result: original + UMAP + Cluster ----
new_expr <- cbind(exprs(ff), UMAP1=umap_res[,1], UMAP2=umap_res[,2], Cluster=km$cluster)
new_ff <- flowFrame(new_expr)
write.FCS(new_ff, filename=opt$output)
cat(opt$output, "\n") # Print output path for logging

# ---- Plot UMAP ----
df <- data.frame(UMAP1=umap_res[,1], UMAP2=umap_res[,2], Cluster=factor(km$cluster))
plt <- ggplot(df, aes(x=UMAP1, y=UMAP2, color=Cluster)) +
  geom_point(size=0.5) + theme_minimal()
ggsave(opt$plot, plot=plt)
