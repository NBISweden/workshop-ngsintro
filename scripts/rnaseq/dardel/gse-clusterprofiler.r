#!/usr/local/bin/Rscript

## R script to run gene set enrichment (over-enrichment analysis) on DE genes

# set custom library path
.libPaths("/sw/courses/ngsintro/rnaseq/dardel/r")

library(clusterProfiler)
library(org.Mm.eg.db)

path_input <- "."
path_output <- "."

message("Reading data ...")

table_res <- read.table(file.path(path_input, "dge_results_full.txt"), sep = "\t", header = TRUE, stringsAsFactors = FALSE, quote = "")
table_res <- table_res[!is.na(table_res$padj), ]
table_res <- table_res[!is.na(table_res$entrezgene_id), ]
table_res <- table_res[!duplicated(table_res$entrezgene_id), ]

universe <- unique(table_res$entrezgene_id)
table_res <- table_res[table_res$padj < 0.05, ]
degs <- unique(table_res$entrezgene_id)

message("Running GSE on CC ...")
gse_cc <- enrichGO(
  gene = as.character(degs),
  universe = as.character(universe),
  OrgDb = org.Mm.eg.db,
  ont = "CC",
  pAdjustMethod = "BH",
  pvalueCutoff = 0.01,
  qvalueCutoff = 0.05,
  readable = TRUE
)

message("Saving CC results ...")
saveRDS(gse_cc, "gse-clusterprofiler-cc.rds")
write.table(gse_cc, file.path(path_output, "gse-cc.txt"), col.names = TRUE, row.names = FALSE, sep = "\t", quote = FALSE)

message("Running GSE on MF ...")
gse_mf <- enrichGO(
  gene = as.character(degs),
  universe = as.character(universe),
  OrgDb = org.Mm.eg.db,
  ont = "MF",
  pAdjustMethod = "BH",
  pvalueCutoff = 0.01,
  qvalueCutoff = 0.05,
  readable = TRUE
)

message("Saving MF results ...")
saveRDS(gse_mf, "gse-clusterprofiler-mf.rds")
write.table(gse_mf, file.path(path_output, "gse-mf.txt"), col.names = TRUE, row.names = FALSE, sep = "\t", quote = FALSE)

message("Running GSE on BP ...")
gse_bp <- enrichGO(
  gene = as.character(degs),
  universe = as.character(universe),
  OrgDb = org.Mm.eg.db,
  ont = "BP",
  pAdjustMethod = "BH",
  pvalueCutoff = 0.01,
  qvalueCutoff = 0.05,
  readable = TRUE
)

message("Saving BP results ...")
saveRDS(gse_bp, "gse-clusterprofiler-bp.rds")
write.table(gse_bp, file.path(path_output, "gse-bp.txt"), col.names = TRUE, row.names = FALSE, sep = "\t", quote = FALSE)

message("Completed.")
