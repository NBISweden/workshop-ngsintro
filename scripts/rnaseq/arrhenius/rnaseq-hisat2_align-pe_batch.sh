#!/bin/bash
## 2026 Roy Francis

#SBATCH -A naiss2026-4-1504-cpu
#SBATCH -p shared
#SBATCH -c 4
#SBATCH -t 2:00:00
#SBATCH -J hisat2-align

set -euo pipefail

cores="${1:-${SLURM_CPUS_PER_TASK:-1}}"

shopt -s nullglob
read1_files=(*_1.fq.gz)

if (( ${#read1_files[@]} == 0 )); then
  echo "No read 1 FASTQ files found in the current directory."
  exit 1
fi

for read1 in "${read1_files[@]}"
do
  sample="${read1%_1.fq.gz}"
  read2="${sample}_2.fq.gz"

  if [[ ! -f "${read2}" ]]; then
    echo "Paired read not found: ${read2}"
    exit 1
  fi

  echo "Mapping ${read1} and ${read2} ..."
  bash ../scripts/rnaseq-hisat2_align-pe.sh "${read1}" "${read2}" "${cores}"
done
