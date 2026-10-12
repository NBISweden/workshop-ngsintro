#!/bin/bash
## 2026 Roy Francis

set -euo pipefail

cores="${1:-${SLURM_CPUS_PER_TASK:-1}}"

shopt -s nullglob
fastq_files=(../1_raw/*.gz)

if (( ${#fastq_files[@]} == 0 )); then
    echo "No FASTQ files found in ../1_raw/."
    exit 1
fi

for fastq_file in "${fastq_files[@]}"
do
	echo "Running ${fastq_file} ..."
	bash ../scripts/rnaseq-fastqc.sh "${fastq_file}" "${cores}"
done
