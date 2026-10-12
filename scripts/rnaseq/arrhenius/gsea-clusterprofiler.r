## R script to run gene set enrichment (over-enrichment analysis) on DE genes

library(clusterProfiler)
library(org.Mm.eg.db)

path_input <- "."
path_output <- "."

message("Reading data ...")

table_res <- read.table(file.path(path_input, "dge_results_full.txt"), sep = "\t", header = TRUE, stringsAsFactors = FALSE, quote = "")
table_res <- table_res[!is.na(table_res$entrezgene_id), ]
table_res <- table_res[is.finite(table_res$log2FoldChange), ]
table_res <- table_res[!duplicated(table_res$entrezgene_id), ]

# order by log2FoldChange
table_res <- table_res[order(table_res$log2FoldChange, decreasing = TRUE), ]
genes <- table_res$log2FoldChange
names(genes) <- as.character(table_res$entrezgene_id)

message("Running GSEA on CC...")
gsea_cc <- gseGO(
  geneList = genes,
  OrgDb = org.Mm.eg.db,
  ont = "CC",
  keyType = "ENTREZID",
  minGSSize = 100,
  maxGSSize = 500,
  pvalueCutoff = 0.05,
  verbose = FALSE
)

message("Saving CC results ...")
saveRDS(gsea_cc, file.path(path_output, "gsea-cc.rds"))
write.table(as.data.frame(gsea_cc), file.path(path_output, "gsea-cc.txt"), col.names = TRUE, row.names = FALSE, sep = "\t", quote = FALSE)

message("Running GSEA on MF...")
gsea_mf <- gseGO(
  geneList = genes,
  OrgDb = org.Mm.eg.db,
  ont = "MF",
  keyType = "ENTREZID",
  minGSSize = 100,
  maxGSSize = 500,
  pvalueCutoff = 0.05,
  verbose = FALSE
)

message("Saving MF results ...")
saveRDS(gsea_mf, file.path(path_output, "gsea-mf.rds"))
write.table(as.data.frame(gsea_mf), file.path(path_output, "gsea-mf.txt"), col.names = TRUE, row.names = FALSE, sep = "\t", quote = FALSE)

message("Running GSEA on BP...")
gsea_bp <- gseGO(
  geneList = genes,
  OrgDb = org.Mm.eg.db,
  ont = "BP",
  keyType = "ENTREZID",
  minGSSize = 100,
  maxGSSize = 500,
  pvalueCutoff = 0.05,
  verbose = FALSE
)

message("Saving BP results ...")
saveRDS(gsea_bp, file.path(path_output, "gsea-bp.rds"))
write.table(as.data.frame(gsea_bp), file.path(path_output, "gsea-bp.txt"), col.names = TRUE, row.names = FALSE, sep = "\t", quote = FALSE)

message("Completed.")
