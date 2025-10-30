#!/bin/bash
## 2024 Roy Francis

#SBATCH -A naiss2023-22-1027
#SBATCH -p shared
#SBATCH -n 4
#SBATCH -t 1:00:00
#SBATCH -J picard

# run from directory /4_picard/
# $1 is a bam file

if [ -z "$1" ]; then
    echo "bam-file not provided."
    exit 1
fi

if [ -z "$2" ]; then
    cores="1"
else
    cores="$2"
fi

# load modules
if command -v sbatch &> /dev/null
then
  module load PDC/24.11
  module load gatk/4.5.0.0
fi

mem=$((cores * 2))
prefix="${1##*/}"
prefix="${prefix/.bam/}"

gatk --java-options -Xmx${mem}g \
  CollectAlignmentSummaryMetrics \
  -R ../reference/Mus_musculus.GRCm38.dna.chromosome.19.fa \
  -I $1 \
  -O ${prefix}-aln.txt

gatk --java-options -Xmx${mem}g \
  CollectRnaSeqMetrics \
  -I $1 \
  -O ${prefix}-rna.txt \
  --REF_FLAT ../reference/Mus_musculus.GRCm38.99-19.gtf.genepred \
  --RIBOSOMAL_INTERVALS ../reference/ribo_interval.txt \
  -STRAND SECOND_READ_TRANSCRIPTION_STRAND
