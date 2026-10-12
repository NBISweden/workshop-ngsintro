#!/bin/bash
## 2026 Roy Francis

#SBATCH -A naiss2026-4-1504-cpu
#SBATCH -p shared
#SBATCH -c 4
#SBATCH -t 1:00:00
#SBATCH -J fcount

set -euo pipefail

# run from directory /5_dge/

cores="${1:-${SLURM_CPUS_PER_TASK:-1}}"

shopt -s nullglob
bam_files=(../3_mapping/*.bam)

if (( ${#bam_files[@]} == 0 )); then
    echo "No BAM files found in ../3_mapping/."
    exit 1
fi

featureCounts \
-a "../reference/Mus_musculus.GRCm38.99-19.gtf" \
-o "counts.txt" \
-F "GTF" \
-t "exon" \
-g "gene_id" \
-p \
-s 0 \
-T "${cores}" \
"${bam_files[@]}"
