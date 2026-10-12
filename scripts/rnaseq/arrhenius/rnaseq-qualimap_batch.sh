#!/bin/bash
## 2026 Roy Francis

#SBATCH -A naiss2026-4-1504-cpu
#SBATCH -p shared
#SBATCH -c 4
#SBATCH -t 2:00:00
#SBATCH -J qualimap

set -euo pipefail

start_time=$(date +%s)
cores="${1:-${SLURM_CPUS_PER_TASK:-1}}"

shopt -s nullglob
bam_files=(../3_mapping/*.bam)

if (( ${#bam_files[@]} == 0 )); then
    echo "No BAM files found in ../3_mapping/."
    exit 1
fi

for bam_file in "${bam_files[@]}"
do
    echo "Running QualiMap on ${bam_file} ..."
    bash ../scripts/rnaseq-qualimap.sh "${bam_file}" "${cores}"
done

end_time=$(date +%s)
echo "Qualimap took $((end_time - start_time)) seconds."
