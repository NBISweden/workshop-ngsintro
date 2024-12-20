#!/bin/bash
## 2024 Roy Francis

## Create ribosome intervals file for Picard CollectRnaSeqMetrics

#SBATCH -A naiss2023-22-1027
#SBATCH -p shared
#SBATCH -n 4
#SBATCH -t 1:30:00
#SBATCH -J ribo-intervals

module load PDC/23.12
module load bioinfo-tools
module load samtools/1.20

annot="Mus_musculus.GRCm38.99-19.gtf"
genome="Mus_musculus.GRCm38.dna.chromosome.19.fa"
chr_size="chr_sizes.txt"
ribo_interval="ribo_interval.txt"

# chr sizes
echo "Running faidx ..."
samtools faidx $genome
awk '{print $1"\t"$2}' ${genome}.fai | sort -k2,2nr > $chr_size

# ribo intervals
echo "Adding chr sizes to $ribo_interval ..."
awk '{printf("@SQ\tSN:%s\tLN:%s\tAS:GRCm38\n", $1, $2)}' $chr_size | \
    grep -v _ > $ribo_interval

# Intervals for rRNA transcripts.
echo "Adding rRNA intervals to $ribo_interval ..."
grep 'gene_biotype "rRNA"' $annot | \
    awk '$3 == "transcript"' | \
    cut -f1,4,5,7,9 | \
    awk '{
        match($0, /transcript_id "([^"]+)"/, arr);
        if (!arr[1]) exit 1;
        print $1"\t"$2"\t"$3"\t"$4"\t"arr[1];
    }' | \
    sort -k1V -k2n -k3n \
>> $ribo_interval

echo "Completed."
