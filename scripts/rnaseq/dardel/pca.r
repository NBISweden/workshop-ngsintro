#!/usr/bin/env Rscript

## R script to create pca plot

# set custom library path
.libPaths("/sw/courses/ngsintro/rnaseq/dardel/r")

library(ggplot2)

path_input <- "."
path_output <- "."

# load vst count data
table_vst <- readRDS(file.path(path_input, "counts_vst_full.rds"))

# create metadata
table_meta <- data.frame(
  accession = c("SRR3222409", "SRR3222410", "SRR3222411", "SRR3222412", "SRR3222413", "SRR3222414"),
  condition = c(rep(c("KO", "Wt"), each = 3)), replicate = rep(1:3, 2), stringsAsFactors = F
)
table_meta$condition <- factor(table_meta$condition, levels = c("Wt", "KO"))
table_meta$replicate <- as.factor(table_meta$replicate)
rownames(table_meta) <- table_meta$accession

# match order of counts and metadata
mth <- match(colnames(table_vst), rownames(table_meta))
table_vst <- table_vst[, mth]
all.equal(rownames(table_meta), colnames(table_vst))

# pca
pcaobj <- prcomp(x = t(table_vst))
pcs <- round(pcaobj$sdev^2 / sum(pcaobj$sdev^2) * 100, 2)

pcamat1 <- as.data.frame(pcaobj$x)
pcamat2 <- merge(pcamat1, table_meta, by = 0)

p <- ggplot(pcamat2, aes(PC1, PC2, colour = condition)) +
  geom_point() +
  geom_text(aes(label = accession), size = 3, nudge_x = 1, hjust = "inward") +
  theme_bw() +
  theme(
    legend.title = element_blank(),
    legend.position = "top",
    legend.justification = "right"
  )

message("Saving plot ...")
ggsave(file.path(path_output, "pca.png"), p, height = 12, width = 12, units = "cm", dpi = 250)
