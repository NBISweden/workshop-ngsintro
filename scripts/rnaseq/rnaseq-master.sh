#!/bin/bash
## 2020 Roy Francis

#SBATCH -A g2019031
#SBATCH -p core
#SBATCH -n 1
#SBATCH -t 2:00:00
#SBATCH -J rnaseq
#SBATCH --mail-type=ALL
#SBATCH --mail-user="roymathewfrancis@gmail.com"
##SBATCH -M snowy

## INTRO COURSE RNA-SEQ TEST SCRIPT

## WHAT DOES THIS SCRIPT DO?
## Copies the 'scripts' directory from base location
## Creates directories
## Runs FastQC on all files using the rnaseq-fastqc.sh script
## Downloads and creates a STAR index for the mouse chr 19 using the script rnaseq-star_index.sh
## Maps fastq files to the STAR index to create sorted BAM files using rnaseq-star_align.sh and rnaseq-star_align_batch.sh
## Runs QualiMap on all BAM files using rnaseq-qualimap.sh
## Runs featureCounts on all BAM files to create one 'counts.txt' using rnaseq-featurecounts.sh
## Runs MultiQC on all output files
## Runs differential gene expression
## Runs bonus functional annotation
## Runs bonus R plots

## INSTRUCTIONS TO RUN THIS SCRIPT
## Add your email to the SBATCH command
## Provide path to base directory
## Make sure the modules are available
## Run the script in an empty directory anywhere on Rackham
## Run sbatch /sw/courses/ngsintro/rnaseq/scripts/rnaseq-master.sh

## VARIABLES --------------------------------------------------------------------

## path to base directory (WITHOUT forward slash at the end)
path_base="/sw/courses/ngsintro/rnaseq"

## if compute is set to long, all steps are run, takes ~3:00 hours on 8 cores
## if compute is set to short, long computations are not run, takes ~6 mins on 2 cores
compute="long"

## number of cores to use
cores="1"

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

echo "Loading modules ..."

## load modules
module load bioinfo-tools
module load FastQC/0.11.8
module load star/2.7.2b
module load samtools/1.9
module load MultiQC/1.8
module load QualiMap/2.2.1
module load subread/2.0.0
module load R/3.6.1
module load R_packages/3.6.1
## trinity uses additional modules

##:<<'comment'
## comment

# copy scripts directory
mkdir rnaseq
cd rnaseq
cp -r ${path_base}/scripts .

## make directories
echo "Creating directories ..."
mkdir 1_raw 2_fastqc 3_mapping 4_qualimap 5_dge 6_multiqc reference
cd reference
mkdir mouse_chr19
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
  bash ../scripts/rnaseq-fastqc_batch.sh
fi

cd ..

fastqc_end_time=`date +%s`
echo "FastQC took $((${fastqc_end_time}-${fastqc_start_time})) seconds."

## star index ------------------------------------------------------------------

echo "Building STAR index ..."
starindex_start_time=`date +%s`

cd reference

if [ ${compute} == "long" ];
 then
  wget -nv ftp://ftp.ensembl.org/pub/release-99/fasta/mus_musculus/dna/Mus_musculus.GRCm38.dna.chromosome.19.fa.gz
  wget -nv ftp://ftp.ensembl.org/pub/release-99/gtf/mus_musculus/Mus_musculus.GRCm38.99.gtf.gz

  gunzip Mus_musculus.GRCm38.dna.chromosome.19.fa.gz
  gunzip Mus_musculus.GRCm38.99.gtf.gz

  # extract chr 19 from gtf
  cat Mus_musculus.GRCm38.99.gtf | grep -E "^#|^19" > Mus_musculus.GRCm38.99-19.gtf

  bash ../scripts/rnaseq-star_index.sh
fi

cd ..

starindex_end_time=`date +%s`
echo "STAR indexing took $((${starindex_end_time}-${starindex_start_time})) seconds."

## soft-link reference index
## ln -s ${path_base}/reference/mouse_chr19/* ./mouse_chr19/

## star mapping ----------------------------------------------------------------

echo "Mapping reads using STAR ..."
star_start_time=`date +%s`

cd 3_mapping
ln -s ../1_raw/*.gz .

if [ ${compute} == "long" ];
 then
  bash ../scripts/rnaseq-star_align_batch.sh

  ## rename
  rename "Aligned.sortedByCoord.out" "" *

  echo "Indexing BAM files ..."

  for i in *.bam
   do
    echo "Indexing ${i} ..."
    samtools index ${i}
   done
fi

cd ..

star_end_time=`date +%s`
echo "STAR mapping took $((${star_end_time}-${star_start_time})) seconds."

## qualimap --------------------------------------------------------------------

echo "Running QualiMap ..."
qualimap_start_time=`date +%s`

cd 4_qualimap

if [ ${compute} == "long" ];
 then
  bash ../scripts/rnaseq-qualimap_batch.sh
fi

cd ..

qualimap_end_time=`date +%s`
echo "QualiMap took $((${qualimap_end_time}-${qualimap_start_time})) seconds."

## featurecounts ---------------------------------------------------------------

echo "Running featureCounts ..."
fcount_start_time=`date +%s`

cd 5_dge

if [ ${compute} == "long" ];
 then
  bash ../scripts/rnaseq-featurecounts.sh
fi

cd ..

fcount_end_time=`date +%s`
echo "featureCounts took $((${fcount_end_time}-${fcount_start_time})) seconds."

## multiqc ---------------------------------------------------------------------
echo "Running MultiQC ..."
multiqc_start_time=`date +%s`

cd 6_multiqc

if [ ${compute} == "long" ];
 then
  multiqc --interactive ../
fi

cd ..

multiqc_end_time=`date +%s`
echo "MultiQC took $((${multiqc_end_time}-${multiqc_start_time})) seconds."

## dge -------------------------------------------------------------------------
echo "Running DGE ..."
dge_start_time=`date +%s`

cd 5_dge
cp ${path_base}/main/5_dge/dge.R .
cp ${path_base}/main/5_dge/counts_full.txt .

if [ ${compute} == "long" ];
 then
  Rscript dge.R
fi

cd ..

dge_end_time=`date +%s`
echo "DGE took $((${dge_end_time}-${dge_start_time})) seconds."

## BONUS -----------------------------------------------------------------------

## functional annotation -------------------------------------------------------

echo "Running Functional annotation ..."
funannot_start_time=`date +%s`

cp ${path_base}/reference/mm*gz ./reference
gunzip ./reference/*.gz

mkdir funannot
cp -r ${path_base}/bonus/funannot/annotate_de_results.R ./funannot/
cd funannot
Rscript annotate_de_results.R
cd ..

funannot_end_time=`date +%s`
echo "Functional annotation took $((${funannot_end_time}-${funannot_start_time})) seconds."

## plots -----------------------------------------------------------------------

echo "Running Plots ..."
plots_start_time=`date +%s`

mkdir plots
cd plots
cp ${path_base}/bonus/plots/*.R .

Rscript pca.R
Rscript ma.R
Rscript volcano.R
Rscript heatmap.R

cd ..

plots_end_time=`date +%s`
echo "Plots took $((${plots_end_time}-${plots_start_time})) seconds."

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
echo "STAR indexing took $((${starindex_end_time}-${starindex_start_time})) seconds."
echo "STAR mapping took $((${star_end_time}-${star_start_time})) seconds."
echo "QualiMap took $((${qualimap_end_time}-${qualimap_start_time})) seconds."
echo "MultiQC took $((${multiqc_end_time}-${multiqc_start_time})) seconds."
echo "featureCounts took $((${fcount_end_time}-${fcount_start_time})) seconds."
echo "DGE took $((${dge_end_time}-${dge_start_time})) seconds."
echo "Functional annotation took $((${funannot_end_time}-${funannot_start_time})) seconds."
echo "Plots took $((${plots_end_time}-${plots_start_time})) seconds."

end_time=`date +%s`
echo ""
echo "Full script took $((${end_time}-${start_time})) seconds."
echo "Space used: $(du -sh .)"
echo ""
echo "============================================"
echo "=== END OF NGS-INTRO RNA-SEQ TEST SCRIPT ==="
echo "============================================"
