#!/bin/bash -l

set -x # print commands before executing
set -e # exit on errors

# get projid or die trying
projid=${1:?No projid specified (required).}
user=${2:-$USER}

# copy files for lab
cp -r /sw/courses/ngsintro/linux/filetypes /proj/$projid/nobackup/$user/
cd /proj/$projid/nobackup/$user/filetypes
tree

# load module
export PATH=$PATH:/sw/courses/ngsintro/linux/uppmax_pipeline_exercise/dummy_scripts

# run programs
reference_indexer -r 0_ref/ad2.fa
align_reads -r 0_ref/ad2.fa -i 0_seq/ad2.fq -o 1_alignment/ad2.sam
sambam_tool -f bam -i 1_alignment/ad2.sam -o 2_bam/ad2.bam
sambam_tool -f sort -i 2_bam/ad2.bam -o 3_sorted/ad2.sorted.bam
sambam_tool -f index -i 3_sorted/ad2.sorted.bam
mv 3_sorted/ad2.sorted.bam.bai 3_sorted/ad2.sorted.bai

# cram
module load bioinfo-tools samtools/1.10
samtools view -C -T 0_ref/ad2.fa -o 4_cram/ad2.cram 3_sorted/ad2.sorted.bam




