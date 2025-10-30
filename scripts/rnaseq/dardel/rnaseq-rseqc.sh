#!/bin/bash
## 2024 Roy Francis

#SBATCH -A naiss2023-22-1027
#SBATCH -p shared
#SBATCH -n 4
#SBATCH -t 1:00:00
#SBATCH -J rseqc

# run from directory /4_rseqc/
# $1 is a bam file

if [ -z "$1" ]; then
    echo "bam-file not provided."
    exit 1
fi

# load modules
if command -v sbatch &> /dev/null
then
  module load PDC/24.11
  module load rseqc/2.6.4
fi

prefix="${1##*/}"
prefix="${prefix/.bam/}"
annot="../reference/Mus_musculus.GRCm38.99-19.gtf.bed"

echo "Running RSeQC on ${prefix}..."

read_distribution.py  -i $1 \
  -r ${annot} \
  > ${prefix}-read-coverage.txt

infer_experiment.py  -i $1  \
  -r ${annot} \
  > ${prefix}-infer-experiment.txt

junction_saturation.py -i $1  \
  -r ${annot} \
  -o ${prefix}-junction-saturation

junction_annotation.py -i $1  \
  -r ${annot} \
  -o ${prefix}-junction-annotation
