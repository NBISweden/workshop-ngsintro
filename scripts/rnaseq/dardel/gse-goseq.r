#!/usr/local/bin/Rscript

## R script to run gene set enrichment (over-enrichment analysis) on DE genes

# set custom lib path
.libPaths("/sw/courses/ngsintro/rnaseq/dardel/r")

library(goseq)
library(GO.db)
library(reactome.db)
library(org.Mm.eg.db)

## prepare directory where results will be saved
export_dir <- "gse-goseq"

message("Reading data ...")

table_res <- read.table("dge_results_full.txt", sep = "\t", header = TRUE, stringsAsFactors = FALSE, quote = "")
table_res <- table_res[!is.na(table_res$padj), ]

# merge results with annotations
table_genes <- read.delim("mm-biomart99-genes.txt", header = T, stringsAsFactors = F)
table_genes <- table_genes[!duplicated(table_genes$ensembl_gene_id), ]
table_genes$entrezgene_id <- as.character(table_genes$entrezgene_id)
table_dge <- merge(table_res, table_genes, by = "ensembl_gene_id")

## select only genes with entrez gene id
## GO term and reactome pathway annotations are mapped to entrez gene ids
table_dge_e <- table_dge[!is.na(table_dge$entrezgene_id), ]

# remove lines with non-unique entrez gene id
table_dge_e <- table_dge_e[!duplicated(table_dge_e$entrezgene_id), ]

## list of all genes included in the analysis
allgenes <- table_dge_e$entrezgene_id

# select the downregulated genes at FDR<0.05
dn.genes <- table_dge_e$entrezgene_id[(table_dge_e$padj < 0.05 & table_dge_e$log2FoldChange < 0)]
gene.vector.de.dn <- as.integer(allgenes %in% dn.genes)
names(gene.vector.de.dn) <- allgenes

up.genes <- table_dge_e$entrezgene_id[(table_dge_e$padj < 0.05 & table_dge_e$log2FoldChange > 0)]
gene.vector.de.up <- as.integer(allgenes %in% up.genes)
names(gene.vector.de.up) <- allgenes

message("Preparing ontology data ...")

# prepare go db
table_go <- as.data.frame(org.Mm.egGO2ALLEGS)
colnames(table_go) <- c("gene_id", "category", "evidence", "ontology")

# read reactome data
table_reactome <- as.data.frame(reactomeEXTID2PATHID)
colnames(table_reactome) <- c("category", "gene_id")
table_reactome_desc <- as.data.frame(reactomePATHID2NAME)
colnames(table_reactome_desc) <- c("category", "path_name")
# remove the duplicates
table_reactome_desc <- table_reactome_desc[!duplicated(table_reactome_desc$category), ]

message("Running functional analyses ...")

## calculate the gene length bias (using nullp, a function from goseq package)
pwf.de.up <- nullp(gene.vector.de.up, "mm9", "knownGene", plot.fit = F)
pwf.de.dn <- nullp(gene.vector.de.dn, "mm9", "knownGene", plot.fit = F)

# goseq on go
go.up <- goseq(pwf.de.up, gene2cat = table_go)
go.up.adj <- go.up[p.adjust(go.up$over_represented_pvalue, method = "BH") < 0.1, ]

go.dn <- goseq(pwf.de.dn, gene2cat = table_go)
go.dn.adj <- go.dn[p.adjust(go.dn$over_represented_pvalue, method = "BH") < 0.1, ]

# goseq on reactome
react.up <- goseq(pwf.de.up, gene2cat = table_reactome)
react.up <- merge(react.up, table_reactome_desc, by = "category")
react.up.adj <- react.up[p.adjust(react.up$over_represented_pvalue, method = "BH") < 0.1, ]

react.dn <- goseq(pwf.de.dn, gene2cat = table_reactome)
react.dn <- merge(react.dn, table_reactome_desc, by = "category")
react.dn.adj <- react.dn[p.adjust(react.dn$over_represented_pvalue, method = "BH") < 0.1, ]

message("Exporting data ...")
dir.create(export_dir)

# save results as tables
write.table(go.up.adj, file.path(export_dir, "go_up.txt"), col.names = TRUE, row.names = FALSE, sep = "\t", quote = FALSE)
write.table(go.dn.adj, file.path(export_dir, "go_down.txt"), col.names = TRUE, row.names = FALSE, sep = "\t", quote = FALSE)
write.table(react.up.adj, file.path(export_dir, "reactome_up.txt"), col.names = TRUE, row.names = FALSE, sep = "\t", quote = FALSE)
write.table(react.dn.adj, file.path(export_dir, "reactome_down.txt"), col.names = TRUE, row.names = FALSE, sep = "\t", quote = FALSE)

message("Completed.")
