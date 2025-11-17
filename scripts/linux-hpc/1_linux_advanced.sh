#!/bin/bash -l

set -x # print commands before executing
set -e # exit on errors

# get projid or die trying
projid=${1:?No projid specified (required).}
user=${2:-$USER}

# copy files for lab


echo -e "\033[0;32m
 ____   ___  _   _ _____
|  _ \ / _ \| \ | | ____|
| | | | | | |  \| |  _|
| |_| | |_| | |\  | |___
|____/ \___/|_| \_|_____|
\033[0m"
