#!/bin/bash -l

set -x # print commands before executing
set -e # exit on errors

# get projid or die trying
projid=${1:?No projid specified (required).}

echo "Starting script 0"
bash 0_linux_intro.sh $projid
echo "Ended script 0"

echo "Starting script 1"
bash 1_linux_advanced.sh $projid
echo "Ended script 1"

echo "Starting script 2"
bash 2_linux_hpc.sh $projid
echo "Ended script 2"

echo "Starting script 3"
bash 3_linux_pipelines.sh $projid
echo "Ended script 3"

echo "Starting script 4"
bash 4_linux_filetypes.sh $projid
echo "Ended script 4"

echo -e "\033[0;32m
  ____  _   _  ____ ____ _____ ____ ____  
 / ___|| | | |/ ___/ ___| ____/ ___/ ___| 
 \___ \| | | | |  | |   |  _| \___ \___ \ 
  ___) | |_| | |__| |___| |___ ___) |__) |
 |____/ \___/ \____\____|_____|____/____/ 
                                          
All test ran without errors.
\033[0m"
