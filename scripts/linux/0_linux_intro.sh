#!/bin/bash -l

set -x # print commands before executing
set -e # exit on errors

# get projid or die trying
projid=${1:?No projid specified (required).}
user=${2:-$USER}


echo "2 Logon to a node"
squeue -u $user

echo "3 Navigation"
ls -l
cd /proj/$projid
cd nobackup
ls -l /home/$user

echo "4 Copy lab files"
mkdir -p /proj/$projid/nobackup/$user
mkdir -p /proj/$projid/nobackup/$user/linux_tutorial
cp -r /sw/courses/ngsintro/linux/linux_tutorial/* /proj/$projid/nobackup/$user/linux_tutorial

echo "5 Unpack files"
cd /proj/$projid/nobackup/$user/linux_tutorial
tar -xzvf files.tar.gz

echo "6 Copying and moving files"
mv important_results/temp_file-1 backed_up_proj_folder/
mv important_results/dna_data_analysis_result_file_that_is_important-you_should_really_use_tab_completion_for_file_names.bam backed_up_proj_folder/
mv a_strange_name a_better_name
ls -l
cp backed_up_proj_folder/last_years_data external_hdd/
ls -l external_hdd/

echo "7 Deleting files"
rm useless_file
rmdir this_is_empty
#rmdir this_has_a_file
rm -r this_has_a_file

echo "8 Open files"
cat old_project/the_best
head /sw/courses/ngsintro/linux/linux_additional-files/large_file

echo "9 Wildcards"
mv part_2/*.txt part_1/
ls -l many_files/*.docx
ls -l many_files/*.txt














