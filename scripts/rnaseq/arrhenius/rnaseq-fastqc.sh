#!/bin/bash
## 2026 Roy Francis

#SBATCH -A naiss2026-4-1504-cpu
#SBATCH -p shared
#SBATCH -c 4
#SBATCH -t 1:00:00
#SBATCH -J fastqc

set -euo pipefail

# run from directory /2_fastqc/
# $1 is a fastq filename
# $2 is the number of cores

if [[ -z "${1:-}" ]]; then
    echo "file.fastq not provided."
    exit 1
fi

cores="${2:-${SLURM_CPUS_PER_TASK:-1}}"

fastqc -t "${cores}" --outdir . "$1"
