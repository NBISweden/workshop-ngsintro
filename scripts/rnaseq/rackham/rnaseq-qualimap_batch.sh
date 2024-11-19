#!/bin/bash
## 2020 Roy Francis

#SBATCH -A g2021013
#SBATCH -p core
#SBATCH -n 1
#SBATCH -t 2:00:00
#SBATCH -J qualimap

start_time=`date +%s`

for i in ../3_mapping/*.bam
do
    echo "Running QualiMap on $i ..."
    bash ../scripts/rnaseq-qualimap.sh $i
done

end_time=`date +%s`
echo "Qualimap took $((${end_time}-${start_time})) seconds."
