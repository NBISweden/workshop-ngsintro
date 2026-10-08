#!/bin/bash
## 2026 Roy Francis

#SBATCH -A naiss2026-4-1504-cpu
#SBATCH -p shared
#SBATCH -n 4
#SBATCH -t 1:00:00
#SBATCH -J hisat2-index

# run from directory /reference/

if [ -z "$1" ]; then
    cores="1"
else
    cores="$1"
fi

hisat2-build \
-p ${cores} \
Mus_musculus.GRCm38.dna.chromosome.19.fa \
mouse_chr19_hisat2/mouse_chr19_hisat2
