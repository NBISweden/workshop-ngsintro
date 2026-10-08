#!/bin/bash
## 2026 Roy Francis

#SBATCH -A naiss2026-4-1504-cpu
#SBATCH -p shared
#SBATCH -n 4
#SBATCH -t 1:00:00
#SBATCH -J fcount

# run from directory /5_dge/

if [ -z "$1" ]; then
    cores="1"
else
    cores="$1"
fi

featureCounts \
-a "../reference/Mus_musculus.GRCm38.99-19.gtf" \
-o "counts.txt" \
-F "GTF" \
-t "exon" \
-g "gene_id" \
-p \
-s 0 \
-T ${cores} \
../3_mapping/*.bam
