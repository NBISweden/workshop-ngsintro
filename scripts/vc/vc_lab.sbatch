#! /bin/bash -l
#
#SBATCH -A naiss2024-22-1150
#SBATCH -p shared
#SBATCH -n 12
#SBATCH -t 1:00:00
#SBATCH -J testvc

module load bioinfo-tools
module load bwa/0.7.17
module load samtools/1.20
module load gatk/4.5.0.0
module load vcftools/0.1.16

echo ""
echo "===================================================="
echo "======= NGS-INTRO VARIANT CALLING TEST SCRIPT ======"
echo "===================================================="

compute="long" #With compute="long" it will run all steps of the script, which will take ca 20 min. Change to test only first steps (<2min)

datadir="/sw/courses/ngsintro/vc/data"
ref="human_g1k_v37_chr2.fasta"
wdir="vc4"

if [ -d $wdir ]; then
    echo "Directory $wdir already exists, will continue, but may want to remove and restart?"
    #    rm -fr $wdir
fi

mkdir -p $wdir
cd $wdir

start_time=`date +%s`

#---GET DATA----------

if [ ! -f $ref ]; then
    echo "Get data"
    ln -s $datadir/ref/$ref
    ln -s $datadir/fastq/HG00097_1.fq
    ln -s $datadir/fastq/HG00097_2.fq
    ln -s $datadir/fastq/HG00100_1.fq
    ln -s $datadir/fastq/HG00100_2.fq
    ln -s $datadir/fastq/HG00101_1.fq
    ln -s $datadir/fastq/HG00101_2.fq
    ln -s $datadir/ref/1000G_phase1.snps.high_confidence.b37.chr2.vcf
    ln -s $datadir/ref/1000G_phase1.snps.high_confidence.b37.chr2.vcf.idx
fi

#----INDEX REFERENCE-----

if [ ! -f $ref.sa ]; then
    echo "Index files"
    bwa index -a bwtsw $ref
    samtools faidx $ref
    gatk --java-options -Xmx4g CreateSequenceDictionary -R $ref -O $(basename $ref .fasta).dict
fi

#---PART1: MAPPING AND VARIANT CALLING ONE SAMPLE---

if [ ! -f HG00097.vcf ]; then
    echo "Part1"
    bwa mem $ref HG00097_1.fq HG00097_2.fq > HG00097.sam
    samtools sort HG00097.sam > HG00097.bam
    samtools index HG00097.bam

    gatk AddOrReplaceReadGroups -I HG00097.bam -O HG00097.rg.bam --RGID rg_HG00097 --RGSM HG00097 --RGPL illumina --RGLB libx --RGPU XXX
    samtools index HG00097.rg.bam

    gatk --java-options -Xmx4g HaplotypeCaller -R $ref -I HG00097.rg.bam -O HG00097.vcf
fi

#---PART2: MAPPING AND VC IN COHORT----------

part1_time=`date +%s`

if [ ${compute} == "long" ]; then
    echo "Part2: COHORT VARIANT CALLING"
    date
    for sample in HG00097 HG00100 HG00101; do
	rg="@RG\tID:rg_"$sample"\tSM:"$sample"\tPU:XXX\tLB:libx\tPL:illumina"
	echo $rg
	bwa mem -t 8 -R "$rg" $ref ${sample}_1.fq ${sample}_2.fq | samtools sort > $sample.bam
	gatk --java-options -Xmx4g MarkDuplicates -I $sample.bam -O $sample.md.bam -M ${sample}_mdmetrics.txt
	samtools index $sample.md.bam 
	gatk --java-options -Xmx4g HaplotypeCaller -R $ref -ERC GVCF -I $sample.md.bam -O $sample.g.vcf
    done
    
    #Combined
    gatk --java-options -Xmx4g CombineGVCFs -R $ref -V HG00097.g.vcf -V HG00100.g.vcf -V HG00101.g.vcf -O cohort.g.vcf
    gatk --java-options -Xmx4g GenotypeGVCFs -R $ref -V cohort.g.vcf -O cohort.vcf
    gatk --java-options -Xmx4g VariantFiltration -R $ref  -V cohort.vcf -O cohort.filtered.vcf  --filter-name QUALfilt --filter-expression "QUAL < 100"
    vcftools --vcf cohort.filtered.vcf --remove-filtered-all --min-meanDP 5 --recode --recode-INFO-all --out cohort.PASS

    #---PART4: GATK BEST_PRACTISE------
    date
    echo "Part4: GATK BEST-PRACTISE"
    for sample in HG00097 HG00100 HG00101; do
	echo $sample
	gatk --java-options -Xmx4g BaseRecalibrator -R $ref --known-sites 1000G_phase1.snps.high_confidence.b37.chr2.vcf -I $sample.md.bam -O $sample.recal.table
	gatk --java-options -Xmx4g ApplyBQSR -R $ref -bqsr-recal-file HG00097.recal.table -I $sample.md.bam -O $sample.recal.bam
	gatk --java-options -Xmx4g HaplotypeCaller -R $ref -ERC GVCF -I $sample.recal.bam -O $sample.g.vcf 
    done
    
    gatk --java-options -Xmx4g CombineGVCFs -R $ref -V HG00097.g.vcf -V HG00100.g.vcf -V HG00101.g.vcf -O cohort.g.vcf
    gatk --java-options -Xmx4g GenotypeGVCFs -R $ref -V cohort.g.vcf -O cohort.recal.vcf
    
    
    gatk --java-options -Xmx4g SelectVariants -R $ref --select-type-to-include SNP -V cohort.recal.vcf -O cohort.snvs.vcf
    
    gatk --java-options -Xmx4g VariantFiltration -R $ref -V cohort.snvs.vcf -O cohort.snvs.filtered.vcf \
	 --filter-name QDfilter --filter-expression "QD < 2.0"  \
	 --filter-name MQfilter --filter-expression "MQ < 40.0"  \
	 --filter-name FSfilter --filter-expression "FS > 60.0"
    
    gatk --java-options -Xmx4g SelectVariants -R $ref  -V cohort.recal.vcf -O cohort.indels.vcf --select-type-to-include INDEL
    
    gatk --java-options -Xmx4g VariantFiltration -R $ref  -V cohort.indels.vcf -O cohort.indels.filtered.vcf \
	 --filter-name QDfilter --filter-expression "QD < 2.0" \
	 --filter-name FSfilter --filter-expression "FS > 200.0"
    
    gatk --java-options -Xmx4g MergeVcfs -I cohort.snvs.filtered.vcf -I cohort.indels.filtered.vcf -O cohort.recal.filtered.vcf    
fi

echo "DONE"
date

end_time=`date +%s`

echo "Part1 took $((${part1_time}-${start_time})) seconds."
echo "Full run took $((${end_time}-${start_time})) seconds comppute=${compute}."
