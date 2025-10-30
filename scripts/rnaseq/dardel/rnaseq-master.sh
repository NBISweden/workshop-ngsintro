#!/bin/bash
## 2024 Roy Francis

#SBATCH -A naiss2025-22-1240
#SBATCH -p shared
#SBATCH -c 4
#SBATCH -t 2:00:00
#SBATCH -J rnaseq
##SBATCH -M snowy

## TRACK RESOURCE USAGE
/cfs/klemming/home/r/royfranc/scripts/common/monitor_usage.sh 60 &

## INTRO COURSE RNA-SEQ TEST SCRIPT

## WHAT DOES THIS SCRIPT DO?
## Copies the 'scripts' directory from base location
## Creates directories
## Runs FastQC on all files using the rnaseq-fastqc.sh script
## Downloads and creates a HISAT2 index for the mouse chr 19 using the script rnaseq-hisat2_index.sh
## Maps fastq files to the HISAT2 index to create sorted BAM files using rnaseq-hisat2_align-pe.sh and rnaseq-hisat2_align-pe_batch.sh
## Runs Picard QC on all BAM files using rnaseq-picard.sh
## Runs featureCounts on all BAM files to create one 'counts.txt' using rnaseq-featurecounts.sh
## Runs MultiQC on all output files
## Runs differential gene expression
## Runs bonus functional annotation
## Runs bonus R plots

## INSTRUCTIONS TO RUN THIS SCRIPT 
## Update UPPMAX project ID
## Update variables below as needed. Set path_base as source rnaseq directory. Set compute as 'short' or 'long'. 'short' takes 4 mins and only creates directories and links. 'long' runs full computation.
## Run the script in an empty directory anywhere on Rackham as shown below
## sbatch /sw/courses/ngsintro/rnaseq/dardel/main/scripts/rnaseq-master.sh

## VARIABLES --------------------------------------------------------------------

# fail fast
set -e

## path to base directory (with trailing slash)
path_base="/sw/courses/ngsintro/rnaseq/dardel"

## if compute is set to short, long computations are not run, takes ~13s on 4 core (~4 GB RAM), final directory size: 430MB
## if compute is set to long, all steps are run, takes ~7 mins on 4 cores (~4 GB RAM), final directory size: 1.5GB
compute="long"

## number of cores to use taken from SBATCH
## cores=${SLURM_NTASKS}
cores=${SLURM_CPUS_PER_TASK}
echo "Number of available cores: ${cores}"

echo ""
echo "============================================"
echo "======= NGS-INTRO RNA-SEQ TEST SCRIPT ======"
echo "============================================"
echo "Base path: ${path_base}"
echo "Compute: ${compute}"
echo "Cores: ${cores}"
echo "============================================"
echo ""

## MAIN ------------------------------------------------------------------------

## start date time
start_time=`date +%s`

# :<<'comment'
# comment

## load modules
# if command -v sbatch &> /dev/null
# then
#   module load PDC/24.11
#   module load fastqc/0.12.1
#   module load hisat2/2.2.1
#   module load samtools/1.20
#   module load multiqc/1.30
#   module load qualimap/2.3
#   module load gatk/4.5.0.0
#   module load subread/2.1.1
#   module load R/4.4.2-cpeGNU-24.11
# fi

# copy scripts directory
if [ -d "rnaseq" ]; then
    rm -rf rnaseq
fi
mkdir rnaseq
cd rnaseq
cp -r ${path_base}/main/scripts .

## make directories
echo "Creating directories ..."
mkdir 1_raw 2_fastqc 3_mapping 4_qualimap 4_picard 5_dge 6_multiqc reference
cd reference
mkdir mouse_chr19_hisat2
cd ..

## create links to fastq raw data
cd 1_raw
echo "Creating softlinks ..."
ln -s ${path_base}/main/1_raw/*.gz .
cd ..

## fastqc ----------------------------------------------------------------------

echo "Running FastQC ..."
fastqc_start_time=`date +%s`

cd 2_fastqc
##ln -s ../1_raw/*.gz .

if [ ${compute} == "long" ];
 then
  bash ../scripts/rnaseq-fastqc_batch.sh ${cores}
fi

cd ..

fastqc_end_time=`date +%s`
echo "FastQC took $((${fastqc_end_time}-${fastqc_start_time})) seconds."

## mapping index ------------------------------------------------------------------

echo "Building aligner index ..."
mappingindex_start_time=`date +%s`

cd reference

if [ ${compute} == "long" ];
 then
  wget -nv ftp://ftp.ensembl.org/pub/release-99/fasta/mus_musculus/dna/Mus_musculus.GRCm38.dna.chromosome.19.fa.gz
  #wget -nv ftp://ftp.ensembl.org/pub/release-99/fasta/mus_musculus/dna/Mus_musculus.GRCm38.dna.primary_assembly.fa.gz
  wget -nv ftp://ftp.ensembl.org/pub/release-99/gtf/mus_musculus/Mus_musculus.GRCm38.99.gtf.gz

  gunzip *.gz

  # extract chr 19 from gtf
  cat Mus_musculus.GRCm38.99.gtf | grep -E "^#|^19" > Mus_musculus.GRCm38.99-19.gtf

  bash ../scripts/rnaseq-hisat2_index.sh ${cores}
  bash ../scripts/rnaseq-flat-ref.sh
  bash ../scripts/rnaseq-ribo-intervals.sh
fi

cd ..

mappingindex_end_time=`date +%s`
echo "HISAT2 indexing took $((${mappingindex_end_time}-${mappingindex_start_time})) seconds."

## soft-link reference index
## ln -s ${path_base}/main/reference/mouse_chr19_hisat2/* ./mouse_chr19_hisat2/

## mapping ----------------------------------------------------------------

echo "Mapping reads ..."
mapping_start_time=`date +%s`

cd 3_mapping
ln -s ../1_raw/*.gz .

if [ ${compute} == "long" ];
 then
  bash ../scripts/rnaseq-hisat2_align-pe_batch.sh ${cores}

  module load PDC/24.11
  module load samtools/1.20
  echo "Indexing BAM files ..."

  for i in *.bam
   do
    echo "Indexing ${i} ..."
    samtools index ${i}
   done
fi

  module unload PDC/24.11
  module unload samtools/1.20
cd ..

mapping_end_time=`date +%s`
echo "Mapping took $((${mapping_end_time}-${mapping_start_time})) seconds."

## qualimap --------------------------------------------------------------------

echo "Running QualiMap ..."
module load PDC/24.11
module load qualimap/2.3
qualimap_start_time=`date +%s`

cd 4_qualimap

if [ ${compute} == "long" ];
 then
  bash ../scripts/rnaseq-qualimap_batch.sh ${cores}
fi

cd ..

qualimap_end_time=`date +%s`
echo "QualiMap took $((${qualimap_end_time}-${qualimap_start_time})) seconds."

module unload qualimap/2.3
module unload PDC/24.11

## qorts --------------------------------------------------------------------

: <<'comment'
echo "Running QoRTs ..."
qorts_start_time=`date +%s`

cd 4_qorts

if [ ${compute} == "long" ];
 then
  bash ../scripts/rnaseq-qorts_batch.sh ${cores}
fi

cd ..

qorts_end_time=`date +%s`
echo "QoRTs took $((${qorts_end_time}-${qorts_start_time})) seconds."
comment

## picard collectrnaseqmetrics -------------------------------------------------

# echo "Running Picard ..."
#  picard_start_time=`date +%s`

# cd 4_picard

# if [ ${compute} == "long" ];
#  then
#   bash ../scripts/rnaseq-picard_batch.sh ${cores}
#   multiqc --interactive ../ -m picard
# fi

# cd ..

# picard_end_time=`date +%s`
# echo "Picard took $((${picard_end_time}-${picard_start_time})) seconds."

## featurecounts ---------------------------------------------------------------

echo "Running featureCounts ..."
fcount_start_time=`date +%s`

cd 5_dge

if [ ${compute} == "long" ];
 then
  bash ../scripts/rnaseq-featurecounts.sh ${cores}
fi

cd ..

fcount_end_time=`date +%s`
echo "featureCounts took $((${fcount_end_time}-${fcount_start_time})) seconds."

## multiqc ---------------------------------------------------------------------

echo "Running MultiQC ..."
module load PDC/24.11
module load multiqc/1.30
multiqc_start_time=`date +%s`

cd 6_multiqc

if [ ${compute} == "long" ];
 then
  multiqc --interactive ../
fi

cd ..

multiqc_end_time=`date +%s`
echo "MultiQC took $((${multiqc_end_time}-${multiqc_start_time})) seconds."
module unload multiqc/1.30
module unload PDC/24.11

## dge -------------------------------------------------------------------------

echo "Running DGE ..."
module load PDC/24.11
module load R/4.4.2-cpeGNU-24.11
dge_start_time=`date +%s`

cp ${path_base}/main/reference/mm*gz ./reference
gunzip ./reference/*.gz
cd 5_dge
cp ${path_base}/main/5_dge/counts_full.txt .

if [ ${compute} == "long" ];
 then
  Rscript --vanilla ${path_base}/main/scripts/dge.r
  Rscript --vanilla ${path_base}/main/scripts/pca.r
	Rscript --vanilla ${path_base}/main/scripts/ma.r
	Rscript --vanilla ${path_base}/main/scripts/volcano.r
	Rscript --vanilla ${path_base}/main/scripts/heatmap.r
 else
  cp ${path_base}/main/5_dge/dge_results_full.rds .
  cp ${path_base}/main/5_dge/counts_vst_full.rds .
  cp ${path_base}/main/5_dge/dge_results_full.txt .
  cp ${path_base}/main/5_dge/counts_vst_full.txt .
fi

cd ..

dge_end_time=`date +%s`
echo "DGE took $((${dge_end_time}-${dge_start_time})) seconds."
module unload R/4.4.2-cpeGNU-24.11
module unload PDC/24.11

## GSE -------------------------------------------------------------------------

echo "Running GSE ..."
module load PDC/24.11
module load R/4.4.2-cpeGNU-24.11
gse_start_time=`date +%s`

cd 5_dge

if [ ${compute} == "long" ];
 then
  Rscript --vanilla ${path_base}/main/scripts/gse-clusterprofiler.r
 else
  cp ${path_base}/main/5_dge/gse-cc.rds .
  cp ${path_base}/main/5_dge/gse-cc.txt .
  cp ${path_base}/main/5_dge/gse-bp.rds .
  cp ${path_base}/main/5_dge/gse-bp.txt .
  cp ${path_base}/main/5_dge/gse-mf.rds .
  cp ${path_base}/main/5_dge/gse-mf.txt .
fi

cd ..

gse_end_time=`date +%s`
echo "GSE took $((${gse_end_time}-${gse_start_time})) seconds."
module unload R/4.4.2-cpeGNU-24.11
module unload PDC/24.11

# ------------------------------------------------------------------------------

echo ""
echo "============================================"
echo "Base path: ${path_base}"
echo "Compute: ${compute}"
echo "Cores: ${cores}"
echo "============================================"
echo ""
echo "Timings:"
echo "FastQC took $((${fastqc_end_time}-${fastqc_start_time})) seconds."
echo "Mapper indexing took $((${mappingindex_end_time}-${mappingindex_start_time})) seconds."
echo "Mapping took $((${mapping_end_time}-${mapping_start_time})) seconds."
echo "QualiMap took $((${qualimap_end_time}-${qualimap_start_time})) seconds."
# echo "QoRTs took $((${qorts_end_time}-${qorts_start_time})) seconds."
# echo "Picard took $((${picard_end_time}-${picard_start_time})) seconds."
echo "MultiQC took $((${multiqc_end_time}-${multiqc_start_time})) seconds."
echo "featureCounts took $((${fcount_end_time}-${fcount_start_time})) seconds."
echo "DGE took $((${dge_end_time}-${dge_start_time})) seconds."
echo "GSE took $((${gse_end_time}-${gse_start_time})) seconds."

end_time=`date +%s`
echo ""
echo "Full script took $((${end_time}-${start_time})) seconds."
echo "Space used: $(du -sh .)"
echo ""
echo "============================================"
echo "=== END OF NGS-INTRO RNA-SEQ TEST SCRIPT ==="
echo "============================================"
