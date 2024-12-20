#!/bin/bash
## 2024 Roy Francis

if [ -z "$1" ]; then
    cores="1"
else
    cores="$1"
fi

for i in ../1_raw/*.gz
do
	echo "Running ${i} ..."
	bash ../scripts/rnaseq-fastqc.sh "${i}" "${cores}"
done
