#!/bin/bash
## 2024 Roy Francis

#SBATCH -A naiss2023-22-1027
#SBATCH -p shared
#SBATCH -n 4
#SBATCH -t 2:00:00
#SBATCH -J hisat2-align

# run from directory /3_mapping/
# $1 single-end read

if [ -z "$1" ]; then
    echo "read not provided."
    exit 1
fi

# load modules
if command -v sbatch &> /dev/null
then
  module load PDC/23.12
  module load bioinfo-tools
  module load HISAT2/2.2.1
fi

# create output file name
prefix="${1##*/}"

hisat2 \
-p 4 \
-x human_hisat2_index/human \
--met-file "${prefix}-metrics.txt" \
-U $1 \
-S "${prefix}.sam" > "${prefix}-summary.txt"
