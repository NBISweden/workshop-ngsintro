#!/bin/bash
## 2020 Roy Francis

#SBATCH -A g2018018
#SBATCH -p core
#SBATCH -n 1
#SBATCH -t 1:00:00
#SBATCH -J star-index

# run from directory /reference/

# load module
module load bioinfo-tools
module load star/2.7.2b

star \
--runMode genomeGenerate \
--runThreadN 1 \
--genomeSAindexNbases 11 \
--genomeDir ./mouse_chr19 \
--genomeFastaFiles ./Mus_musculus.GRCm38.dna.chromosome.19.fa \
--sjdbGTFfile ./Mus_musculus.GRCm38.99.gtf
