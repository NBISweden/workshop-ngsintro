## R script to generate coverage and sashimi plots for a specific genomic region using BAM files and a GTF annotation file

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

gtf_file <- "../reference/Mus_musculus.GRCm38.99-19.gtf"

library(Gviz)
library(GenomicRanges)

gen <- "mm10"
chr <- sub("^chr", "", args[1]) # match the Ensembl chromosome names in the GTF and BAM files
start_position <- suppressWarnings(as.integer(args[2]))
end_position <- suppressWarnings(as.integer(args[3]))

if (is.na(start_position) || is.na(end_position) || start_position < 1 || end_position <= start_position) {
  stop("Start and stop must be positive integers with stop greater than start.", call. = FALSE)
}

message("Reading BAM files ...")

# Collect bam filenames from bam folder
bams <- list.files(path_input, pattern = "\\.bam$", full.names = TRUE, recursive = TRUE)

if (length(bams) == 0) {
  stop("No BAM files found in the current directory.", call. = FALSE)
}

# Allow for using different chromosome names than ucsc
options(ucscChromosomeNames = FALSE)

# create tracks
itrack <- IdeogramTrack(genome = gen, chromosome = chr)
gtrack <- GenomeAxisTrack()
grtrack <- GeneRegionTrack(
  range = gtf_file,
  genome = gen,
  chromosome = chr,
  name = "Genes",
  transcriptAnnotation = "symbol"
)
atrack <- lapply(bams, function(bam) {
  AlignmentsTrack(bam = bam, isPaired = TRUE, start = start_position, end = end_position, genome = gen, chromosome = chr, name = basename(bam))
})

# merge all tracks
toplot <- append(list(itrack, gtrack, grtrack), atrack)

width <- 14
height <- 14

# plot
message("Exporting coverage plot ...")
png(file.path(path_output, paste0("coverage-", chr, "-", start_position, "-", end_position, ".png")), width = width, height = height, units = "cm", res = 300)
plotTracks(toplot, type = "coverage", from = start_position, to = end_position)
dev.off()

message("Exporting sashimi plot ...")
png(file.path(path_output, paste0("sashimi-", chr, "-", start_position, "-", end_position, ".png")), width = width, height = height, units = "cm", res = 300)
plotTracks(toplot, type = "sashimi", from = start_position, to = end_position)
dev.off()
