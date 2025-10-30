#!/bin/bash
## 2024 Roy Francis

#SBATCH -A naiss2023-22-1027
#SBATCH -p shared
#SBATCH -n 4
#SBATCH -t 1:00:00
#SBATCH -J qualimap

# run from directory /4_qualimap/
# $1 is a bam file

if [ -z "$1" ]; then
    echo "bam-file not provided."
    exit 1
fi

if [ -z "$2" ]; then
    cores="1"
else
    cores="$2"
fi

# load modules
if command -v sbatch &> /dev/null
then
  module load PDC/24.11
  module load qualimap/2.3
fi

# available memory in GB
mem=$((cores * 2))

prefix="${1##*/}"
prefix="${prefix/.bam/}"

#export DISPLAY=""
unset DISPLAY
#export DISPLAY=:0

qualimap rnaseq -pe \
-bam $1 \
-gtf "../reference/Mus_musculus.GRCm38.99-19.gtf" \
-outdir "../4_qualimap/${prefix}/" \
-outfile "${prefix}" \
-outformat "HTML" \
--java-mem-size="${mem}G" >& "${prefix}-qualimap.log"
