#!/usr/bin/env Rscript

## R script to run differential gene expression

# set custom lib path
.libPaths("/sw/courses/ngsintro/rnaseq/dardel/r")

library(edgeR)
library(DESeq2)

path_input <- "."
path_output <- "."

# metadata
table_meta <- data.frame(
  accession = c("SRR3222409", "SRR3222410", "SRR3222411", "SRR3222412", "SRR3222413", "SRR3222414"), condition = c(rep(c("KO", "Wt"), each = 3)),
  replicate = rep(1:3, 2)
)
table_meta$condition <- factor(as.character(table_meta$condition), levels = c("Wt", "KO"))
# table_meta$condition <- relevel(table_meta$condition,"Wt")
rownames(table_meta) <- table_meta$accession

# reading in data
message("Reading count data ...")
data_counts <- read.delim(file.path(path_input, "counts_full.txt"), skip = 1)
table_counts <- as.matrix(data_counts[, -c(1:6)])
row.names(table_counts) <- data_counts$Geneid

# fix column labels
colnames(table_counts) <- sub(".*?(SRR[0-9]+).*", "\\1", colnames(table_counts))

# match order of counts and metadata
mth <- match(colnames(table_counts), rownames(table_meta))
table_counts <- table_counts[, mth]
# check if metadata and counts match
all.equal(rownames(table_meta), colnames(table_counts))

# remove genes with low counts
# keep genes that have minimum 1 CPM across 3 samples (since group has three replicates)
message(paste0("Number of genes before filtering: ", nrow(table_counts)))
keepgenes <- rowSums(edgeR::cpm(table_counts) > 1) >= 3
table_counts <- table_counts[keepgenes, ]
message(paste0("Number of genes after filtering: ", nrow(table_counts)))

message("Preview of count table:")
print(head(table_counts))
message("\nView of metadata table:")
print(table_meta)

## deseq2
message("Running DESeq2 ...")

# run deseq2
d <- DESeqDataSetFromMatrix(countData = table_counts, colData = table_meta, design = ~condition)
d <- DESeq2::estimateSizeFactors(d, type = "ratio")
d <- DESeq2::estimateDispersions(d)

dg <- nbinomWaldTest(d)
print(resultsNames(dg))
res <- results(dg, contrast = c("condition", "KO", "Wt"), alpha = 0.05)
message("Summary of DEGs:")
summary(res)

# lfc shrink to correct fold changes
res1 <- lfcShrink(dg, contrast = c("condition", "KO", "Wt"), res = res, type = "normal")

# convert table to data.frame
table_res <- as.data.frame(res1)
table_res$ensembl_gene_id <- rownames(table_res)

# merge results with annotations
table_genes <- read.delim("../reference/mm-biomart99-genes.txt", header = T, stringsAsFactors = F)
table_genes <- table_genes[!duplicated(table_genes$ensembl_gene_id), ]
table_genes <- table_genes[!duplicated(table_genes$external_gene_name), ]
table_res <- merge(table_res, table_genes, by = "ensembl_gene_id")
table_res <- table_res[!is.na(table_res$gene), ]

# alternative solution to convert ensembl gene id to gene symbol
# library(clusterProfiler)
# library(org.Mm.eg.db)
# eg <- bitr(table_res$ensembl_gene_id, fromType = "ENSEMBL", toType = "SYMBOL", OrgDb = "org.Mm.eg.db")
# colnames(eg) <- c("ensembl_gene_id", "gene")
# table_res <- merge(table_res, eg, by = "ensembl_gene_id")

message("Preview of DEG table:")
print(head(table_res))

message("Exporting results ...")
write.table(table_res, file.path(path_output, "dge_results_full.txt"), sep = "\t", quote = F, row.names = F)
saveRDS(table_res, "dge_results_full.rds")

# export vst counts
cv <- as.data.frame(assay(DESeq2::varianceStabilizingTransformation(d, blind = T)), check.names = F)
write.table(cv, file.path(path_output, "counts_vst_full.txt"), sep = "\t", dec = ".", quote = FALSE)
saveRDS(cv, "counts_vst_full.rds")

cat("Completed ...\n")
