# usr/bin/env Rscript

## R script to create ma plot

message("Creating MA plot ...")

# set custom library path
.libPaths("/sw/courses/ngsintro/rnaseq/dardel/r")

library(ggplot2)

path_input <- "."
path_output <- "."

# load deg data
table_res <- readRDS(file.path(path_input, "dge_results_full.rds"))
table_res <- table_res[!is.na(table_res$padj), ]
table_res$sig <- ifelse(table_res$padj < 0.05, "Sig", "NotSig")

p <- ggplot(table_res, aes(x = baseMean, y = log2FoldChange, colour = sig)) +
  geom_point(size = 0.7, alpha = 0.5) +
  scale_x_log10() +
  scale_colour_manual(values = c("grey40", "#80b1d3")) +
  labs(
    x = expression(Log[10] ~ " Mean normalized counts"),
    y = expression(Log[2] ~ " Fold change")
  ) +
  theme_bw() +
  theme(
    legend.title = element_blank(),
    legend.position = "top",
    legend.justification = "right"
  )

message("Saving plot ...")
ggsave(file.path(path_output, "ma.png"), p, height = 12, width = 12, units = "cm", dpi = 250)
