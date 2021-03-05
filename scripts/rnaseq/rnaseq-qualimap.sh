#!/bin/bash
## 2020 Roy Francis

#SBATCH -A g2021013
#SBATCH -p core
#SBATCH -n 1
#SBATCH -t 1:00:00
#SBATCH -J qualimap

# run from directory /4_qualimap/
# $1 is a bam file

if [ -z "$1" ]; then
    echo "bam-file not provided."
    exit 1
fi

# load modules
if ( hostname | grep -q uppmax );
then
  module load bioinfo-tools
  module load QualiMap/2.2.1
fi

# available memory in GB
mem="6"

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
