#!/bin/bash
## 2020 Roy Francis

#SBATCH -A g2021013
#SBATCH -p core
#SBATCH -n 1
#SBATCH -t 2:00:00
#SBATCH -J hisat2-align

# run from directory /3_mapping/
# $1 paired-end read1
# $2 paired-end read2

if [ -z "$1" ]; then
    echo "read1 not provided."
    exit 1
fi

if [ -z "$2" ]; then
    echo "read2 not provided."
    exit 1
fi

# load modules
if ( hostname | grep -q uppmax );
then
  module load bioinfo-tools
  module load HISAT2/2.1.0
  module load samtools/1.8
fi

# create output file name
prefix="${1##*/}"
prefix="${prefix/_*/}"

hisat2 \
-p 1 \
-x ../reference/mouse_chr19_hisat2/mouse_chr19_hisat2 \
--summary-file "${prefix}.summary" \
-1 $1 \
-2 $2 | samtools sort -O BAM > "${prefix}.bam"
