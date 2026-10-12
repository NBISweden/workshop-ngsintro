#!/bin/bash
## 2026 Roy Francis

#SBATCH -A naiss2026-4-1504-cpu
#SBATCH -p shared
#SBATCH -c 4
#SBATCH -t 1:00:00
#SBATCH -J hisat2-index

set -euo pipefail

# run from directory /reference/

cores="${1:-${SLURM_CPUS_PER_TASK:-1}}"

hisat2-build \
-p "${cores}" \
Mus_musculus.GRCm38.dna.chromosome.19.fa \
mouse_chr19_hisat2/mouse_chr19_hisat2
