#!/usr/bin/env Rscript

# set custom library path
.libPaths("/sw/courses/ngsintro/rnaseq/dardel/r")

# path_input <- "/crex/course_data/ngsintro/rnaseq/main_full/3_mapping/"
path_input <- "."
path_output <- "."

# For running as command line script and parsing options from command line
args <- commandArgs(trailingOnly = TRUE)
# test if correct number of arguments are given as input: if not, return an error
if (length(args) < 3) {
  stop("Please supply chromosome number as well as start and stop position for the plot\n Example: Rscript gene.r chr19 6062821 6067842",
    call. = FALSE
  )
}

library(Gviz)
library(EnsDb.Mmusculus.v79)
library(GenomicRanges)

edb <- EnsDb.Mmusculus.v79
gen <- "mm10"
chr <- args[1] # parse the first argument after the r-script to chr
start <- as.integer(args[2]) # parse the second argument after the r-script to start
stop <- as.integer(args[3]) # parse the second argument after the r-script to stop

message("Reading BAM files ...")

# Collect bam filenames from bam folder
bams <- list.files(path_input, pattern = "*.bam$", full.names = TRUE, recursive = TRUE)

# Allow for using different chromosome names than ucsc
options(ucscChromosomeNames = FALSE)

# create tracks
itrack <- IdeogramTrack(genome = gen, chromosome = chr)
gtrack <- GenomeAxisTrack()
grtrack <- getGeneRegionTrackForGviz(edb, chromosome = chr, start = start, end = stop)
genome(grtrack) <- gen
atrack <- lapply(bams, function(bam) {
  AlignmentsTrack(bam = bam, isPaired = TRUE, start = start, end = end, genome = gen, chromosome = chr, name = basename(bam))
})

# merge all tracks
toplot <- append(list(itrack, gtrack, GeneRegionTrack(grtrack)), atrack)

width <- 14
height <- 14

# plot
message("Exporting coverage plot ...")
png(file.path(path_output, paste0("coverage-", chr, "-", start, "-", stop, ".png")), width = width, height = height, units = "cm", res = 300)
plotTracks(toplot, type = c("coverage"), from = start, to = stop)
dev.off()

message("Exporting sashimi plot ...")
png(file.path(path_output, paste0("sashimi-", chr, "-", start, "-", stop, ".png")), width = width, height = height, units = "cm", res = 300)
plotTracks(toplot, type = c("sashimi"), from = start, to = stop)
dev.off()
