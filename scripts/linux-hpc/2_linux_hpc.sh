#!/bin/bash -l

set -x # print commands before executing
set -e # exit on errors

# get projid or die trying
projid=${1:?No projid specified (required).}
user=${2:-$USER}


echo "3 Copy files for lab"
cp -r /sw/courses/ngsintro/linux/uppmax_tutorial/ /cfs/klemming/projects/supr/$projid/$user
cd /cfs/klemming/projects/supr/$projid/$user/uppmax_tutorial
ls -l

echo "4 Run programs"
module load bioinfo-tools samtools
#samtools
samtools view -h data.bam
samtools view -h data.bam > data.sam
ls -l
cat data.sam

echo "5 Modules"
#module list
#module avail

echo "6 Submitting a job"
echo "#! /bin/bash -l
#SBATCH -A $projid
#SBATCH -p shared
#SBATCH -J Template_script
#SBATCH -t 01:00:00

# load some modules
module load bioinfo-tools

# go to some directory
cd /cfs/klemming/projects/supr/$projid/

# do something
echo Hello world!" > job_template.sbatch
sbatch job_template.sbatch

echo "7 Job queue"
squeue -u $user


echo -e "\033[0;32m 
 ____   ___  _   _ _____ 
|  _ \ / _ \| \ | | ____| 
| | | | | | |  \| |  _| 
| |_| | |_| | |\  | |___ 
|____/ \___/|_| \_|_____| 
\033[0m" 
