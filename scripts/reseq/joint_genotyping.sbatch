#!/bin/bash

#SBATCH -A g2019031
#SBATCH -p core
#SBATCH -n 1
#SBATCH -t 1:00:00
#SBATCH -J jointGenotyping

## load modules
module load bioinfo-tools
module load bwa/0.7.17
module load samtools/1.10
module load GATK/4.1.4.1

## loop through the samples:
for sample in HG00097 HG00100 HG00101;
do
  echo "Now analyzing: "$sample
  #bwa mem
  bwa mem -R "@RG\\tID:readgroupx\\tPU:flowcellx_lanex\\tSM:"$sample"\\tLB:libraryx\\tPL:illumina" -t 1 human_g1k_v37_chr2.fasta $sample"_1.fq" $sample"_2.fq" | samtools sort > $sample".bam"
  
  #samtools index
  samtools index $sample".bam"

  #HaplotypeCaller
  gatk --java-options -Xmx7g HaplotypeCaller -R human_g1k_v37_chr2.fasta -ERC GVCF -I $sample".bam" -O $sample".g.vcf" 
done

#CombineGVCFs:
gatk --java-options -Xmx7g CombineGVCFs -R human_g1k_v37_chr2.fasta -V HG00097.g.vcf -V HG00100.g.vcf -V HG00101.g.vcf -O cohort.g.vcf

#GenotypeGVCFs:
gatk --java-options -Xmx7g GenotypeGVCFs -R human_g1k_v37_chr2.fasta -V cohort.g.vcf -O cohort.vcf