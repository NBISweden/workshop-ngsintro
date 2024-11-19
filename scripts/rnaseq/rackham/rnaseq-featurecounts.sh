#!/bin/bash
## 2020 Roy Francis

#SBATCH -A g2021013
#SBATCH -p core
#SBATCH -n 1
#SBATCH -t 1:00:00
#SBATCH -J fcount

# run from directory /5_dge/

# load modules
if ( hostname | grep -q uppmax );
then
  module load bioinfo-tools
  module load subread/2.0.0
fi

featureCounts \
-a "../reference/Mus_musculus.GRCm38.99-19.gtf" \
-o "counts.txt" \
-F "GTF" \
-t "exon" \
-g "gene_id" \
-p \
-s 0 \
-T 1 \
../3_mapping/*.bam
