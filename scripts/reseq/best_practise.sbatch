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
module load picard/2.20.4

ref="/sw/courses/ngsintro/reseq/data/ref"

## loop through the samples:
for sample in HG00097 HG00100 HG00101;
do
  echo "\n\nNow analyzing: "$sample"\n\n"
  bwa mem -R "@RG\\tID:readgroupx\\tPU:flowcellx_lanex\\tSM:"$sample"\\tLB:libraryx\\tPL:illumina" -t 1 human_g1k_v37_chr2.fasta $sample"_1.fq" $sample"_2.fq" | samtools sort > $sample".bam"
  
  samtools index $sample".bam"
  
  java -Xmx7g -jar $PICARD_HOME/picard.jar MarkDuplicates I=$sample".bam"" O=$sample".md.bam" M=$sample"_mdmetrics.txt"
  
  gatk --java-options -Xmx7g BaseRecalibrator -R human_g1k_v37_chr2.fasta -I $sample".md.bam" --known-sites $ref"/1000G_phase1.snps.high_confidence.b37.chr2.vcf" -O $sample".recal.table"
  
  gatk --java-options -Xmx7g ApplyBQSR -R human_g1k_v37_chr2.fasta -I $sample.md.bam --bqsr-recal-file $sample".recal.table"" -O $sample".recal.bam"
  
  gatk --java-options -Xmx7g HaplotypeCaller -R human_g1k_v37_chr2.fasta -ERC GVCF -I $sample".bam" -O $sample".g.vcf" 
done

gatk --java-options -Xmx7g CombineGVCFs -R human_g1k_v37_chr2.fasta -V HG00097.g.vcf -V HG00100.g.vcf -V HG00101.g.vcf -O cohort.g.vcf

gatk --java-options -Xmx7g GenotypeGVCFs -R human_g1k_v37_chr2.fasta -V cohort.g.vcf -O cohort.vcf

gatk --java-options -Xmx7g SelectVariants -R human_g1k_v37_chr2.fasta -V cohort.vcf --selectType SNP -O cohort.snvs.vcf
  
gatk --java-options -Xmx7g VariantFiltration -R human_g1k_v37_chr2.fasta -V cohort.snvs.vcf -O cohort.snvs.filtered.vcf --filterName QDfilter --filterExpression "QD < 2.0" --filterName MQfilter --filterExpression "MQ < 40.0"  --filterName FSfilter --filterExpression "FS > 60.0"

gatk --java-options -Xmx7g SelectVariants -R human_g1k_v37_chr2.fasta -V cohort.vcf --selectType INDEL -o cohort.indels.vcf

gatk --java-options -Xmx7g VariantFiltration -R human_g1k_v37_chr2.fasta -V cohort.indels.vcf -O cohort.indels.filtered.vcf --filterName QDfilter --filterExpression "QD < 2.0" --filterName FSfilter --filterExpression "FS > 200.0"

java -Xmx7g -jar $PICARD_HOME/picard.jar MergeVcfs I=cohort.snps.filtered.vcf I=cohort.indels.filtered.vcf O=cohort.filtered.vcf