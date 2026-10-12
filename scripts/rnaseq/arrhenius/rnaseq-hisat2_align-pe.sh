#!/bin/bash
## 2026 Roy Francis

#SBATCH -A naiss2026-4-1504-cpu
#SBATCH -p shared
#SBATCH -c 1
#SBATCH -t 2:00:00
#SBATCH -J hisat2-align

set -euo pipefail

# run from directory /3_mapping/
# $1 paired-end read1
# $2 paired-end read2

if [[ -z "${1:-}" ]]; then
    echo "read1 not provided."
    exit 1
fi

if [[ -z "${2:-}" ]]; then
    echo "read2 not provided."
    exit 1
fi

cores="${3:-${SLURM_CPUS_PER_TASK:-1}}"

# create output file name
prefix="${1##*/}"
prefix="${prefix%_1.fq.gz}"

hisat2 \
-p "${cores}" \
-x ../reference/mouse_chr19_hisat2/mouse_chr19_hisat2 \
--summary-file "${prefix}.summary" \
-1 "$1" \
-2 "$2" | samtools sort -O BAM -o "${prefix}.bam"
