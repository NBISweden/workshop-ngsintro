#!/bin/bash
## 2020 Roy Francis

#SBATCH -A g2021013
#SBATCH -p core
#SBATCH -n 1
#SBATCH -t 1:00:00
#SBATCH -J hisat2-index

# run from directory /reference/

# load module
if ( hostname | grep -q uppmax );
then
  module load bioinfo-tools
  module load HISAT2/2.1.0
fi

hisat2-build \
-p 1 \
Mus_musculus.GRCm38.dna.chromosome.19.fa \
mouse_chr19_hisat2/mouse_chr19_hisat2
