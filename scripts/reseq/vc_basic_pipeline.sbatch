#!/bin/bash
## 2020 Roy Francis and Malin Larsson

## Set cores (-n) as same as set below under variables

#SBATCH -A g2021013
#SBATCH -p core
#SBATCH -n 1
#SBATCH -t 1:00:00
#SBATCH -J vc
#SBATCH --mail-type=ALL
##SBATCH --mail-user="malin.larsson@scilifelab.se"

## INTRO COURSE VARIANT CALLING TEST SCRIPT

## WHAT DOES THIS SCRIPT DO?
## Creates a ngsworkflow directory and moves into it.
## creates symbolic links to fastq files and reference genome
## creates bwa, samtools and picard indices of reference genome
## ...etc, performs all steps in the basic variant calling exersice (step 1 & 2).

## INSTRUCTIONS TO RUN THIS SCRIPT
## Add your email to the SBATCH command
## If needed, update path to base directory (path_base below)
## If needed, update path to the home directory (path_home below)
## Make sure the modules are available
## The script can be started from anywhere on Rackham
## It will create the folder $path_home/ngsworkflow (if not already there)
## And write all output there
## Run sbatch /sw/courses/ngsintro/reseq/scripts/vc_pipeline.sbatch

## VARIABLES --------------------------------------------------------------------

# fail fast
set -e

## path to base directory for the course data (WITHOUT forward slash at the end)
path_base="/sw/courses/ngsintro/reseq/data"
## should be /sw/courses/ngsintro/reseq/data on rackham.
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
if ( hostname | grep -q uppmax ) ;
 then
  module load bioinfo-tools
  module load bwa/0.7.17
  module load samtools/1.10
  module load GATK/4.1.4.1
 fi

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
ln -s ${path_base}/fastq/HG00100_1.fq
ln -s ${path_base}/fastq/HG00100_2.fq
ln -s ${path_base}/fastq/HG00101_1.fq
ln -s ${path_base}/fastq/HG00101_2.fq

## index reference genome ----------------------------------------------------------------------
echo "Indexing the genome ..."
index_start_time=`date +%s`

if [ ${compute} == "long" ];
 then
  bwa index -a bwtsw human_g1k_v37_chr2.fasta
  samtools faidx human_g1k_v37_chr2.fasta
  gatk --java-options -Xmx7g CreateSequenceDictionary -R human_g1k_v37_chr2.fasta -O human_g1k_v37_chr2.dict
fi

index_end_time=`date +%s`
echo "Indexing took $((${index_end_time}-${index_start_time})) seconds."

## Per sample mapping and variant calling -------------------------------------------------------------

echo "Per sample mapping and variant calling ..."
per_sample_start_time=`date +%s`

## compute
if [ ${compute} == "long" ];
 then

 ## loop through the samples:
 for sample in HG00097 HG00100 HG00101;
  do
    echo "\n\nNow analyzing: "$sample"\n\n"
    bwa mem -R "@RG\\tID:readgroupx\\tPU:flowcellx_lanex\\tSM:"$sample"\\tLB:libraryx\\tPL:illumina" -t 1 human_g1k_v37_chr2.fasta $sample"_1.fq" $sample"_2.fq" | samtools sort > $sample".bam"
    samtools index $sample".bam"
    #Per sample vcf file
    gatk --java-options -Xmx7g HaplotypeCaller -R human_g1k_v37_chr2.fasta -I $sample".bam" -O $sample".vcf"
    #Per sample g.vcf file
    gatk --java-options -Xmx7g HaplotypeCaller -R human_g1k_v37_chr2.fasta -ERC GVCF -I $sample".bam" -O $sample".g.vcf"
 done
fi

per_sample_end_time=`date +%s`
echo "Per sample mapping and variant calling took $((${per_sample_end_time}-${per_sample_start_time})) seconds."

## Combine GVCFs  ----------------------------------------------------------------

echo "Combine GVCFs..."
cgvcf_start_time=`date +%s`

if [ ${compute} == "long" ];
 then
  gatk --java-options -Xmx7g CombineGVCFs -R human_g1k_v37_chr2.fasta -V HG00097.g.vcf -V HG00100.g.vcf -V HG00101.g.vcf -O cohort.g.vcf
fi

cgvcf_end_time=`date +%s`
echo "Joint variant calling took $((${cgvcf_end_time}-${cgvcf_start_time})) seconds."

## Genotype GVCF--------------------------------------------------------------------

echo "genotype GVCF ..."
ib_start_time=`date +%s`

if [ ${compute} == "long" ];
 then
  gatk --java-options -Xmx7g GenotypeGVCFs -R human_g1k_v37_chr2.fasta -V cohort.g.vcf -O cohort.vcf
fi

ib_end_time=`date +%s`
echo "Genotype GVCF took $((${ib_end_time}-${ib_start_time})) seconds."



echo ""
echo "============================================"
echo "Base path: ${path_base}"
echo "Compute: ${compute}"
echo "Cores: ${cores}"
echo "============================================"
echo ""
echo "Timings:"
echo "Indexing took $((${index_end_time}-${index_start_time})) seconds."
echo "Per sample mapping and variant calling took $((${per_sample_end_time}-${per_sample_start_time})) seconds."
echo "Joint variant calling took $((${cgvcf_end_time}-${cgvcf_start_time})) seconds."
echo "Genotype GVCF took $((${ib_end_time}-${ib_start_time})) seconds."
echo "Merging SNVs and indels took $((${jg_end_time}-${jg_start_time})) seconds."
end_time=`date +%s`
echo ""
echo "Full script took $((${end_time}-${start_time})) seconds."
echo "Space used: $(du -sh .)"
echo ""
echo "===================================================="
echo "=== END OF BASIC VARIANT CALLING TEST SCRIPT ==="
echo "===================================================="
