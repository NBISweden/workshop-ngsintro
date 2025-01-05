#!/usr/bin/env Rscript

## R script to create heatmap plot

Sys.setenv(R_REMOTES_NO_X11 = "true")

# set custom library path
.libPaths("/sw/courses/ngsintro/rnaseq/dardel/r")

# load library
library(pheatmap)

path_input <- "."
path_output <- "."

# load deg data
table_res <- readRDS(file.path(path_input, "dge_results_full.rds"))
table_res <- table_res[!is.na(table_res$padj), ]
table_res <- table_res[table_res$padj < 0.05, ]

# order by padj or lfc and pick top 50 genes
# table_res <- table_res[order(table_res$padj),]
table_res <- table_res[order(-abs(table_res$log2FoldChange)), ]
table_res <- table_res[1:50, ]

# load vst count data
table_vst <- readRDS(file.path(path_input, "counts_vst_full.Rds"))
table_vst <- table_vst[table_res$ensembl_gene_id, ]
mt1 <- match(rownames(table_vst), table_res$ensembl_gene_id)
table_vst <- table_vst[mt1, ]
all.equal(rownames(table_vst), table_res$ensembl_gene_id)
rownames(table_vst) <- table_res$external_gene_name

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

col_cond <- c("#fb8072", "#8dd3c7")[table_meta$condition]
names(col_cond) <- table_meta$condition

col_rep <- c("#80b1d3", "#fdb462", "#bebada")[table_meta$replicate]
names(col_rep) <- table_meta$replicate

message("Saving plot ...")
png(file.path(path_output, "heatmap.png"), height = 24, width = 12, units = "cm", res = 300)
pheatmap::pheatmap(table_vst,
  annotation_col = table_meta[, c("condition", "replicate")], scale = "row", border_color = NA,
  annotation_colors = list(condition = col_cond, replicate = col_rep)
)
dev.off()
