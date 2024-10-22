#!/bin/bash
#SBATCH -A naiss2023-22-1027
#SBATCH -p shared
#SBATCH --mem=6Gb 
#SBATCH -t 2:00:00
#SBATCH -J BestPracticeGT

## load modules
module load bioinfo-tools
module load bwa/0.7.17
module load samtools/1.20
module load GATK/4.3.0.0

path_base="/sw/courses/ngsintro/reseq/data"
# define path to reference genome
ref="/sw/courses/ngsintro/reseq/data/ref"

ln -s ${path_base}/ref/human_g1k_v37_chr2.fasta
ln -s ${path_base}/fastq/HG00097_1.fq
ln -s ${path_base}/fastq/HG00097_2.fq
ln -s ${path_base}/fastq/HG00100_1.fq
ln -s ${path_base}/fastq/HG00100_2.fq
ln -s ${path_base}/fastq/HG00101_1.fq
ln -s ${path_base}/fastq/HG00101_2.fq

bwa index -a bwtsw human_g1k_v37_chr2.fasta
samtools faidx human_g1k_v37_chr2.fasta
gatk --java-options -Xmx4g CreateSequenceDictionary -R human_g1k_v37_chr2.fasta -O human_g1k_v37_chr2.dict

## loop through the samples:
for sample in HG00097 HG00100 HG00101;
do
  echo "\n\nNow analyzing: "$sample"\n\n"
  bwa mem -R "@RG\tID:readgroupx\tPU:flowcellx_lanex\tSM:"$sample"\tLB:libraryx\tPL:illumina" -t 14 human_g1k_v37_chr2.fasta $sample"_1.fq" $sample"_2.fq" | samtools sort > $sample".bam"

  samtools index $sample".bam"

  gatk --java-options -Xmx4g MarkDuplicates -I $sample".bam" -O $sample".md.bam" -M $sample"_mdmetrics.txt"

  gatk --java-options -Xmx4g BaseRecalibrator -R human_g1k_v37_chr2.fasta -I $sample".md.bam" --known-sites $ref"/1000G_phase1.snps.high_confidence.b37.chr2.vcf" -O $sample".recal.table"

  gatk --java-options -Xmx4g ApplyBQSR -R human_g1k_v37_chr2.fasta -I $sample".md.bam" --bqsr-recal-file $sample".recal.table" -O $sample".recal.bam"

  gatk --java-options -Xmx4g HaplotypeCaller -R human_g1k_v37_chr2.fasta -ERC GVCF -I $sample".bam" -O $sample".g.vcf"

done

gatk --java-options -Xmx4g CombineGVCFs -R human_g1k_v37_chr2.fasta -V HG00097.g.vcf -V HG00100.g.vcf -V HG00101.g.vcf -O cohort.g.vcf

gatk --java-options -Xmx4g GenotypeGVCFs -R human_g1k_v37_chr2.fasta -V cohort.g.vcf -O cohort.vcf

gatk --java-options -Xmx4g SelectVariants -R human_g1k_v37_chr2.fasta -V cohort.vcf --select-type-to-include SNP -O cohort.snvs.vcf

gatk --java-options -Xmx4g VariantFiltration -R human_g1k_v37_chr2.fasta -V cohort.snvs.vcf -O cohort.snvs.filtered.vcf --filter-name QDfilter --filter-expression "QD < 2.0" --filter-name MQfilter --filter-expression "MQ < 40.0"  --filter-name FSfilter --filter-expression "FS > 60.0"

gatk --java-options -Xmx4g SelectVariants -R human_g1k_v37_chr2.fasta -V cohort.vcf --select-type-to-include INDEL -O cohort.indels.vcf

gatk --java-options -Xmx4g VariantFiltration -R human_g1k_v37_chr2.fasta -V cohort.indels.vcf -O cohort.indels.filtered.vcf --filter-name QDfilter --filter-expression "QD < 2.0" --filter-name FSfilter --filter-expression "FS > 200.0"

gatk --java-options -Xmx4g MergeVcfs -I cohort.snvs.filtered.vcf -I cohort.indels.filtered.vcf -O cohort.filtered.vcf
