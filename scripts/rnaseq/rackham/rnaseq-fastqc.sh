#!/bin/bash
## 2020 Roy Francis

#SBATCH -A g2021013
#SBATCH -p core
#SBATCH -n 1
#SBATCH -t 1:00:00
#SBATCH -J fastqc

# run from directory /2_fastqc/
# $1 is a fastq filename
# $2 is the number of cores

if [ -z "$1" ]; then
    echo "file.fastq not provided."
    exit 1
fi

# load modules
if ( hostname | grep -q uppmax );
then
  module load bioinfo-tools
  module load FastQC/0.11.8
fi

fastqc -t 1 -o . "$1"
