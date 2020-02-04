#!/bin/bash
## 2020 Roy Francis

#SBATCH -A g2018028
#SBATCH -p core
#SBATCH -n 1
#SBATCH -t 2:00:00
#SBATCH -J star-align

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
module load star/2.7.2b

# create output file name
prefix="${1##*/}"
prefix="${prefix/_*/}"

star \
--runMode alignReads \
--genomeDir "../reference/mouse_chr19" \
--runThreadN 1 \
--readFilesCommand zcat \
--readFilesIn $1 $2 \
--sjdbGTFfile "../reference/Mus_musculus.GRCm38.99.gtf" \
--outFileNamePrefix "$prefix" \
--outSAMtype BAM SortedByCoordinate
