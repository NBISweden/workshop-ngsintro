#!/bin/bash -l

set -x # print commands before executing
set -e # exit on errors

# get projid or die trying
projid=${1:?No projid specified (required).}
user=${2:-$USER}

# copy files for lab
mkdir /proj/$projid/nobackup/$user/uppmax_pipeline_exercise
cp -r /sw/courses/ngsintro/linux/uppmax_pipeline_exercise/data/* /proj/$projid/nobackup/$user/uppmax_pipeline_exercise
cd /proj/$projid/nobackup/$user/uppmax_pipeline_exercise

# load module
export PATH=$PATH:/sw/courses/ngsintro/linux/uppmax_pipeline_exercise/dummy_scripts

# run programs
filter_reads -h

cd /proj/$projid/nobackup/$user/uppmax_pipeline_exercise/exomeSeq
filter_reads -i raw_data/my_reads.rawdata.fastq -o raw_data/my_reads.filtered.fastq
align_reads -i raw_data/my_reads.filtered.fastq -o my_reads.filtered.sam -r /sw/data/uppnex/reference/Homo_sapiens/hg19/concat_rm/Homo_sapiens.GRCh37.57.dna_rm.concat.fa
find_snps -i raw_data/my_reads.filtered.fastq -o my_reads.filtered.vcf -r /sw/data/uppnex/reference/Homo_sapiens/hg19/concat_rm/Homo_sapiens.GRCh37.57.dna_rm.concat.fa







