#!/bin/bash
## 2026 Roy Francis

#SBATCH -A naiss2026-4-1504-cpu
#SBATCH -p shared
#SBATCH -n 4
#SBATCH -t 2:00:00
#SBATCH -J qualimap

start_time=`date +%s`

if [ -z "$1" ]; then
    cores="1"
else
    cores="$1"
fi

for i in ../3_mapping/*.bam
do
    echo "Running QualiMap on $i ..."
    bash ../scripts/rnaseq-qualimap.sh $i ${cores}
done

end_time=`date +%s`
echo "Qualimap took $((${end_time}-${start_time})) seconds."
