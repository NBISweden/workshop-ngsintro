#!/usr/bin/env Rscript

## R script to create volcano plot

# set custom library path
.libPaths("/sw/courses/ngsintro/rnaseq/dardel/r")

library(ggplot2)
library(ggrepel)

path_input <- "."
path_output <- "."

# load deg data
table_res <- readRDS(file.path(path_input, "dge_results_full.rds"))
table_res <- table_res[!is.na(table_res$padj), ]
table_res$sig <- ifelse(table_res$padj < 0.05, "Sig", "NotSig")
table_res <- table_res[order(table_res$padj), ]

p <- ggplot(table_res, aes(x = log2FoldChange, y = -log10(padj))) +
  geom_point(aes(color = sig), size = 0.7, alpha = 0.5) +
  # geom_text(data = head(table_res, 10), aes(label = external_gene_name), size = 2.5, nudge_x = 0.5) +
  ggrepel::geom_text_repel(data = head(table_res, 15), aes(label = external_gene_name), force_pull = 0.8, size = 2.5, segment.size = 0.14, show.legend = FALSE) +
  scale_colour_manual(values = c("grey40", "brown2")) +
  labs(
    x = expression(Log[2] ~ " Fold change"),
    y = expression(-Log[10] ~ " BH adjusted p-value")
  ) +
  theme_bw() +
  theme(
    legend.title = element_blank(),
    legend.position = "top",
    legend.justification = "right"
  )

message("Saving plot ...")
ggsave(file.path(path_output, "volcano.png"), p, height = 12, width = 12, units = "cm", dpi = 250)
