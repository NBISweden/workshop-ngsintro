#!/bin/bash
## 2024 Roy Francis

#SBATCH -A naiss2023-22-1027
#SBATCH -p shared
#SBATCH -n 4
#SBATCH -t 2:00:00
#SBATCH -J qorts

start_time=`date +%s`

if [ -z "$1" ]; then
    cores="1"
else
    cores="$1"
fi

for i in ../3_mapping/*.bam
do
    echo "Running QoRTs on $i ..."
    bash ../scripts/rnaseq-qorts.sh $i ${cores}
done

end_time=`date +%s`
echo "QoRTs took $((${end_time}-${start_time})) seconds."