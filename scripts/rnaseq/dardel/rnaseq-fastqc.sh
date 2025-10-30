#!/bin/bash
## 2024 Roy Francis

#SBATCH -A naiss2023-22-1027
#SBATCH -p shared
#SBATCH -n 4
#SBATCH -t 1:00:00
#SBATCH -J fastqc

# run from directory /2_fastqc/
# $1 is a fastq filename
# $2 is the number of cores

if [ -z "$1" ]; then
    echo "file.fastq not provided."
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
  module load fastqc/0.12.1
fi

fastqc -t $cores -o . "$1"
