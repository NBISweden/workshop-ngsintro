#!/bin/bash
## 2024 Roy Francis

#SBATCH -A naiss2023-22-1027
#SBATCH -p shared
#SBATCH -n 4
#SBATCH -t 1:00:00
#SBATCH -J qorts

set -e

# run from directory /4_qorts/
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
  module load QoRTs/1.3.6
fi

# available memory in GB
mem=$((cores * 2))
prefix="${1##*/}"
prefix="${prefix/.bam/}"

echo "Running QoRTs on ${prefix}..."

QoRTs QC \
--RNA \
--generatePlots \
--generateMultiPlot \
--stranded \
--noGzipOutput \
--verbose \
--maxReadLength 101 \
--outfilePrefix ${prefix} \
--genomeFA ../reference/Mus_musculus.GRCm38.dna.chromosome.19.fa \
$1 \
../reference/Mus_musculus.GRCm38.99-19.gtf \
./${prefix}-qorts
