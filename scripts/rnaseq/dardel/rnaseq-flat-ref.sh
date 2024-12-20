#!/bin/bash
## 2024 Roy Francis

## Convert GTF to genePred format for GATK CollectRnaSeqMetrics

#SBATCH -A naiss2023-22-1027
#SBATCH -p shared
#SBATCH -n 4
#SBATCH -t 1:00:00
#SBATCH -J flatref

module load PDC/23.12
module load bioinfo-tools
module load ucsc-utilities/v421

annot="Mus_musculus.GRCm38.99-19.gtf"

gtfToGenePred \
  -genePredExt \
  -geneNameAsName2 \
  -ignoreGroupsWithoutExons \
  ${annot} \
  Mus_musculus.GRCm38.99-19.gtf.genepred

cat Mus_musculus.GRCm38.99-19.gtf.genepred | awk 'BEGIN { OFS="\t"} {print $12, $1, $2, $3, $4, $5, $6, $7, $8, $9, $10}' > Mus_musculus.GRCm38.99-19.gtf.genepred
