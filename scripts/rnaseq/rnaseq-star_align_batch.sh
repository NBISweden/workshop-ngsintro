#!/bin/bash
## 2020 Roy Francis

## find only files for read 1 and extract the sample name
lines=$(find *_1.fq.gz | sed "s/_1.fq.gz//")

for i in ${lines}
do
  ## use the sample name and add suffix (_1.fq.gz or _2.fq.gz)
  echo "Mapping ${i}_1.fq.gz and ${i}_2.fq.gz ..."
  bash ../scripts/rnaseq-star_align.sh ${i}_1.fq.gz ${i}_2.fq.gz
done
