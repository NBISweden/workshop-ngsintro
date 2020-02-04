#!/bin/bash
## 2020 Roy Francis and Malin Larsson

## Set cores (-n) as same as set below under variables

#SBATCH -A g2019031
#SBATCH -p core
#SBATCH -n 1
#SBATCH -t 4:30:00
#SBATCH -J vc
#SBATCH --mail-type=ALL
#SBATCH --mail-user="malin.larsson@scilifelab.se"


## INTRO COURSE VARIANT CALLING TEST SCRIPT

## WHAT DOES THIS SCRIPT DO?
## Creates a ngsworkflow directory and moves into it.
## creates symbolic links to fastq files and reference genome
## creates bwa, samtools and picard indices of reference genome
## ...etc, performs all steps in variant calling exersice.

## INSTRUCTIONS TO RUN THIS SCRIPT
## Add your email to the SBATCH command
## If needed, update path to base directory (path_base below)
## If needed, update path to the home directory (path_home below)
## Make sure the modules are available
## The script can be started from anywhere on Rackham
## It will create the folder $path_home/ngsworkflow (if not already there)
## And write all output there
## Run sbatch /sw/share/compstore/courses/ngsintro/reseq/scripts/vc_pipeline.sbatch

## VARIABLES --------------------------------------------------------------------

## path to base directory for the course data (WITHOUT forward slash at the end)
path_base="/sw/share/compstore/courses/ngsintro/reseq/data/"
## should be /sw/share/compstore/courses/ngsintro/reseq/data on rackham.
path_home=$PWD

## if compute is set to long, all steps are run, takes ~30 minutes on 1 core
compute="long"

## number of cores to use
cores="1"

echo ""
echo "============================================"
echo "======= NGS-INTRO VARIANT CALLING TEST SCRIPT ======"
echo "============================================"
echo "Base path: ${path_base}"
echo "Compute: ${compute}"
echo "Cores: ${cores}"
echo "============================================"
echo ""

## MAIN ------------------------------------------------------------------------

## start date time
start_time=`date +%s`

echo "Loading modules ..."

## load modules
module load bioinfo-tools
module load bwa/0.7.17
module load samtools/1.8
module load GATK/3.7
module load picard/2.10.3
module load vcftools/0.1.15
module load annovar/2017.07.16

## make directories
echo "Creating directories ..."
mkdir -p ${path_home}/ngsworkflow
cd ${path_home}/ngsworkflow
echo $PWD


## create links to reference genome and fastq files
echo "Creating softlinks ..."
ln -s ${path_base}/ref/human_g1k_v37_chr2.fasta
ln -s ${path_base}/fastq/HG00097_1.fq
ln -s ${path_base}/fastq/HG00097_2.fq


## index reference genome ----------------------------------------------------------------------
echo "Indexing BWA ..."
bwaindex_start_time=`date +%s`

if [ ${compute} == "long" ];
 then
	bwa index -a bwtsw human_g1k_v37_chr2.fasta
fi

bwaindex_end_time=`date +%s`
echo "BWA indexing took $((${bwaindex_end_time}-${bwaindex_start_time})) seconds."


## Samtools and Picard indices ------------------------------------------------------------------
echo "Building Samtools and Picard indices ..."
spindex_start_time=`date +%s`

if [ ${compute} == "long" ];
 then
	samtools faidx human_g1k_v37_chr2.fasta
    java -Xmx7g -jar $PICARD_HOME/picard.jar CreateSequenceDictionary R=human_g1k_v37_chr2.fasta O=human_g1k_v37_chr2.dict
fi


spindex_end_time=`date +%s`
echo "Samtools and Picard indices took $((${spindex_end_time}-${spindex_start_time})) seconds."

## Aligning reads -------------------------------------------------------------

echo "Aligning reads ..."
bwa_start_time=`date +%s`

## compute
if [ ${compute} == "long" ];
 then
 	bwa mem -t 1 human_g1k_v37_chr2.fasta HG00097_1.fq HG00097_2.fq > HG00097.sam
fi

bwa_end_time=`date +%s`
echo "BWA took $((${bwa_end_time}-${bwa_start_time})) seconds."



## convert sam to bam ----------------------------------------------------------------
echo "Converting sam to bam..."
csb_start_time=`date +%s`

if [ ${compute} == "long" ];
 then
	java -Xmx7g -jar $PICARD_HOME/picard.jar AddOrReplaceReadGroups INPUT=HG00097.sam OUTPUT=HG00097.bam SORT_ORDER=coordinate RGID=HG00097-id RGLB=HG00097-lib RGPL=ILLUMINA RGPU=HG00097-01 RGSM=HG00097
fi

csb_end_time=`date +%s`
echo "Converting sam to bam took $((${csb_end_time}-${csb_start_time})) seconds."


## index bam --------------------------------------------------------------------
echo "Indexing bam ..."
ib_start_time=`date +%s`

if [ ${compute} == "long" ];
 then
	java -Xmx7g -jar $PICARD_HOME/picard.jar BuildBamIndex INPUT=HG00097.bam
fi

ib_end_time=`date +%s`
echo "indexing bam took $((${ib_end_time}-${ib_start_time})) seconds."

## Mark duplicates ---------------------------------------------------------------
echo "Mark duplicates and index new bam..."
md_start_time=`date +%s`

if [ ${compute} == "long" ];
 then
  java -Xmx7g -jar $PICARD_HOME/picard.jar MarkDuplicates \
  INPUT=HG00097.bam\
  OUTPUT=HG00097.dedup.bam \
  METRICS_FILE=HG00097.metrics \
  READ_NAME_REGEX=null

  java -Xmx7g -jar $PICARD_HOME/picard.jar BuildBamIndex INPUT=HG00097.dedup.bam

fi

md_end_time=`date +%s`
echo "Mark duplication took $((${md_end_time}-${md_start_time})) seconds."

## BQSR ---------------------------------------------------------------------
echo "Running BQSR ..."
bqsr_start_time=`date +%s`

if [ ${compute} == "long" ];
 then
    java -Xmx7g -jar $GATK_HOME/GenomeAnalysisTK.jar -T BaseRecalibrator \
    -R human_g1k_v37_chr2.fasta \
    -I HG00097.dedup.bam \
    -o HG00097.calibration_table  \
    -knownSites ${path_base}/ref/1000G_phase1.snps.high_confidence.b37.chr2.vcf

    java -Xmx7g -jar $GATK_HOME/GenomeAnalysisTK.jar -T PrintReads \
    -R human_g1k_v37_chr2.fasta \
    -BQSR HG00097.calibration_table \
    -I HG00097.dedup.bam \
    -o HG00097.dedup.bqsr.bam
fi

bqsr_end_time=`date +%s`
echo "BQSR took $((${bqsr_end_time}-${bqsr_start_time})) seconds."

## Variant calling -------------------------------------------------------------------------
echo "Running HaplotypeCaller ..."
hc_start_time=`date +%s`

if [ ${compute} == "long" ];
 then
	java -Xmx7g -jar $GATK_HOME/GenomeAnalysisTK.jar -T HaplotypeCaller \
    -R human_g1k_v37_chr2.fasta \
    --emitRefConfidence GVCF \
    -I HG00097.dedup.bqsr.bam \
    -o HG00097.g.vcf
fi

if [ ${compute} == "short" ];
 then
 	echo 'nothing is done'
fi

hc_end_time=`date +%s`
echo "HaplotypeCaller took $((${hc_end_time}-${hc_start_time})) seconds."

## Second sample -------------------------------------------------------------------------
echo "Running second sample..."
ss_start_time=`date +%s`

if [ ${compute} == "long" ];
 then
    ln -s ${path_base}/fastq/HG00100_1.fq
    ln -s ${path_base}/fastq/HG00100_2.fq
    bwa mem -t 1 human_g1k_v37_chr2.fasta HG00100_1.fq HG00100_2.fq > HG00100.sam

    java -Xmx7g -jar $PICARD_HOME/picard.jar AddOrReplaceReadGroups INPUT=HG00100.sam OUTPUT=HG00100.bam SORT_ORDER=coordinate RGID=HG00100-id RGLB=HG00100-lib RGPL=ILLUMINA RGPU=HG00100-01 RGSM=HG00100
    java -Xmx7g -jar $PICARD_HOME/picard.jar BuildBamIndex INPUT=HG00100.bam
    java -Xmx7g -jar $PICARD_HOME/picard.jar MarkDuplicates \
        INPUT=HG00100.bam\
        OUTPUT=HG00100.dedup.bam \
        METRICS_FILE=HG00100.metrics \
        READ_NAME_REGEX=null
    java -Xmx7g -jar $PICARD_HOME/picard.jar BuildBamIndex INPUT=HG00100.dedup.bam

    java -Xmx7g -jar $GATK_HOME/GenomeAnalysisTK.jar -T BaseRecalibrator \
        -R human_g1k_v37_chr2.fasta \
        -I HG00100.dedup.bam \
        -o HG00100.calibration_table  \
        -knownSites ${path_base}/ref/1000G_phase1.snps.high_confidence.b37.chr2.vcf

    java -Xmx16g -jar $GATK_HOME/GenomeAnalysisTK.jar -T PrintReads \
        -R human_g1k_v37_chr2.fasta \
        -BQSR HG00100.calibration_table \
        -I HG00100.dedup.bam \
        -o HG00100.dedup.bqsr.bam

    java -Xmx7g -jar $GATK_HOME/GenomeAnalysisTK.jar -T HaplotypeCaller \
        -R human_g1k_v37_chr2.fasta \
        --emitRefConfidence GVCF \
        -I HG00100.dedup.bqsr.bam \
        -o HG00100.g.vcf
fi

ss_end_time=`date +%s`
echo "Second sample took $((${ss_end_time}-${ss_start_time})) seconds."


##  Joint genotyping -------------------------------------------------------------------------
echo "Running joint genotyping..."
jg_start_time=`date +%s`

if [ ${compute} == "long" ];
 then
    java -Xmx7g -jar $GATK_HOME/GenomeAnalysisTK.jar -T GenotypeGVCFs \
    -R human_g1k_v37_chr2.fasta \
    --variant HG00097.g.vcf \
    --variant HG00100.g.vcf \
    -o raw_variants.vcf

fi

jg_end_time=`date +%s`
echo "Joint genotyping took $((${jg_end_time}-${jg_start_time})) seconds."

##  SNP filtering -------------------------------------------------------------------------
echo "Running variant filtering for snps..."
vfs_start_time=`date +%s`

if [ ${compute} == "long" ];
 then
    java -Xmx7g -jar $GATK_HOME/GenomeAnalysisTK.jar -T SelectVariants \
    -R human_g1k_v37_chr2.fasta \
    -V raw_variants.vcf \
    -selectType SNP \
    -o raw_snps.vcf

    java -Xmx7g -jar $GATK_HOME/GenomeAnalysisTK.jar -T VariantFiltration \
    -R human_g1k_v37_chr2.fasta \
    -V raw_snps.vcf \
    -o filtered_snps.vcf \
    --filterExpression "QD < 2.0" --filterName QDfilter \
    --filterExpression "MQ < 40.0" --filterName MQfilter \
    --filterExpression "FS > 60.0" --filterName FSfilter
fi

vfs_end_time=`date +%s`
echo "Variant filtering for snps took $((${vfs_end_time}-${vfs_start_time})) seconds."

##  Indel filtering -------------------------------------------------------------------------
echo "Running variant filtering for snps..."
vfi_start_time=`date +%s`

if [ ${compute} == "long" ];
 then
    java -Xmx7g -jar $GATK_HOME/GenomeAnalysisTK.jar -T SelectVariants \
    -R human_g1k_v37_chr2.fasta \
    -V raw_variants.vcf \
    -selectType INDEL \
    -o raw_indels.vcf

    java -Xmx7g -jar $GATK_HOME/GenomeAnalysisTK.jar -T VariantFiltration \
    -R human_g1k_v37_chr2.fasta \
    -V raw_indels.vcf \
    -o filtered_indels.vcf \
    --filterExpression "QD < 2.0" --filterName QDfilter \
    --filterExpression "FS > 200.0" --filterName FSfilter
fi

vfi_end_time=`date +%s`
echo "Variant filtering for indels took $((${vfi_end_time}-${vfi_start_time})) seconds."

##  Merge SNPs and Indels -------------------------------------------------------------------------
echo "Merging SNPs and Indels..."
merge_start_time=`date +%s`

if [ ${compute} == "long" ];
 then
   java -Xmx7g -jar $GATK_HOME/GenomeAnalysisTK.jar -T CombineVariants \
    -R human_g1k_v37_chr2.fasta \
    --variant:snp filtered_snps.vcf \
    --variant:indel filtered_indels.vcf \
    -o my_variants_filtered.vcf \
  -genotypeMergeOptions PRIORITIZE -priority snp,indel
fi

merge_end_time=`date +%s`
echo "Merging snps and indels took $((${merge_end_time}-${merge_start_time})) seconds."

## VCF tools -------------------------------------------------------------------------
echo "Analysing with vcf tools..."
vcftools_start_time=`date +%s`

if [ ${compute} == "long" ];
 then
    vcftools --vcf my_variants_filtered.vcf \
    --out passed \
    --remove-filtered-all \
    --recode --recode-INFO-all
fi

vcftools_end_time=`date +%s`
echo "VCFtools took $((${vcftools_end_time}-${vcftools_start_time})) seconds."


## Annovar -------------------------------------------------------------------------
echo "Annotate with annovar..."
annovar_start_time=`date +%s`

if [ ${compute} == "long" ];
 then
    convert2annovar.pl -format vcf4 -allsample -withfreq  my_variants_filtered.vcf > my_variants_filtered.annovar
    table_annovar.pl my_variants_filtered.annovar $ANNOVAR_HOME/humandb -buildver hg19 -outfile myanno -remove -protocol refGene,snp138,1000g2015aug_all,1000g2015aug_eur,1000g2015aug_afr -operation g,f,f,f,f
fi

annovar_end_time=`date +%s`
echo "Annovar took $((${annovar_end_time}-${annovar_start_time})) seconds."

##comment
# ------------------------------------------------------------------------------

echo ""
echo "============================================"
echo "Base path: ${path_base}"
echo "Compute: ${compute}"
echo "Cores: ${cores}"
echo "============================================"
echo ""
echo "Timings:"
echo "BWA index took $((${bwaindex_end_time}-${bwaindex_start_time})) seconds."
echo "Samtools and picard indexing took $((${spindex_end_time}-${spindex_start_time})) seconds."
#echo "BWA mapping took $((${bwa_end_time}-${bwa_start_time})) seconds."
echo "Convert sam to bam took $((${csb_end_time}-${csb_start_time})) seconds."
echo "Index bam took $((${ib_end_time}-${ib_start_time})) seconds."
echo "Mark duplicates took $((${md_end_time}-${md_start_time})) seconds."
echo "BSQR took $((${bqsr_end_time}-${bqsr_start_time})) seconds."
echo "HaplotypeCaller took $((${hc_end_time}-${hc_start_time})) seconds."
echo "Second sample took $((${ss_end_time}-${ss_start_time})) seconds."
echo "Joint genotyping took $((${jg_end_time}-${jg_start_time})) seconds."
echo "Variant filtering for snps took $((${vfs_end_time}-${vfs_start_time})) seconds."
echo "Variant filtering for indels took $((${vfi_end_time}-${vfi_start_time})) seconds."
echo "Merging snps and indels took $((${merge_end_time}-${merge_start_time})) seconds."
echo "VCFtools took $((${vcftools_end_time}-${vcftools_start_time})) seconds."
echo "Annovar took $((${annovar_end_time}-${annovar_start_time})) seconds."

end_time=`date +%s`
echo ""
echo "Full script took $((${end_time}-${start_time})) seconds."
echo "Space used: $(du -sh .)"
echo ""
echo "===================================================="
echo "=== END OF NGS-INTRO VARIANT CALLING TEST SCRIPT ==="
echo "===================================================="
