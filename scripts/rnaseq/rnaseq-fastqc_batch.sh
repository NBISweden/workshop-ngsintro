#!/bin/bash
## 2020 Roy Francis

for i in ../1_raw/*.gz
do
	echo "Running $i ..."
	../scripts/rnaseq-fastqc.sh "$i"
done
