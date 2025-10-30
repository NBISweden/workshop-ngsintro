#!/bin/bash
## 2024 Roy Francis

#SBATCH -A naiss2023-22-1027
#SBATCH -p shared
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

if [ -z "$3" ]; then
    cores="1"
else
    cores="$3"
fi

# load modules
if command -v sbatch &> /dev/null
then
  module load PDC/24.11
  module load hisat2/2.2.1
  module load samtools/1.20
fi

# create output file name
prefix="${1##*/}"
prefix="${prefix/_*/}"

hisat2 \
-p ${cores} \
-x ../reference/mouse_chr19_hisat2/mouse_chr19_hisat2 \
--summary-file "${prefix}.summary" \
-1 $1 \
-2 $2 | samtools sort -O BAM > "${prefix}.bam"
