## R script to create heatmap plot

message("Creating heatmap plot ...")

options(bitmapType = "cairo")

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
table_res <- head(table_res, 50)

if (nrow(table_res) == 0) {
  stop("No significant genes are available for the heatmap.", call. = FALSE)
}

# load vst count data
table_vst <- readRDS(file.path(path_input, "counts_vst_full.rds"))
gene_match <- match(table_res$ensembl_gene_id, rownames(table_vst))
if (anyNA(gene_match)) {
  stop("Some significant genes are missing from the VST count matrix.", call. = FALSE)
}
table_vst <- table_vst[gene_match, , drop = FALSE]
stopifnot(identical(rownames(table_vst), table_res$ensembl_gene_id))
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
mth <- match(rownames(table_meta), colnames(table_vst))
if (anyNA(mth)) {
  stop("Some metadata samples are missing from the VST count matrix.", call. = FALSE)
}
table_vst <- table_vst[, mth, drop = FALSE]
stopifnot(identical(rownames(table_meta), colnames(table_vst)))

col_cond <- c(Wt = "#fb8072", KO = "#8dd3c7")

col_rep <- c("1" = "#80b1d3", "2" = "#fdb462", "3" = "#bebada")

message("Saving plot ...")
png(file.path(path_output, "heatmap.png"), height = 24, width = 12, units = "cm", res = 300)
pheatmap::pheatmap(table_vst,
  annotation_col = table_meta[, c("condition", "replicate")], scale = "row", border_color = NA,
  annotation_colors = list(condition = col_cond, replicate = col_rep)
)
dev.off()
