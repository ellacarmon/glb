#!/bin/bash
#
# Created By: GitHub Copilot
# Based on original import.sh by: ellacarmon
# Github: github.com/ellacarmon
# License: MIT
#
echo "#####################################"
echo "## Welcome to glb bash installer  ##"
echo "#####################################"
echo ""
echo "First argument will be the path to install the glb script, default is home folder"
echo "Second argument will be the source profile folder, default is ~/.zshrc"
echo ""

PATH_TO_INSTALL=$HOME/

if [[ -n $1 ]]; then
    PATH_TO_INSTALL=$1
fi

echo "The path of the script is ${PATH_TO_INSTALL}"
echo ""
echo "Cloning script to ${PATH_TO_INSTALL}"
cd ${PATH_TO_INSTALL}
git clone https://github.com/ellacarmon/glb.git
cd glb
cp get_latest_branches.sh ${PATH_TO_INSTALL}

SOURCE_FOLDER=~/.zshrc
if [[ -n $2 ]]; then
    SOURCE_FOLDER=$2
fi

echo "source folder is ${SOURCE_FOLDER}"
echo "adding glb bash alias"
ALIAS='alias glb="'${PATH_TO_INSTALL}'/get_latest_branches.sh"'

echo ${ALIAS} >> ${SOURCE_FOLDER}
source ${SOURCE_FOLDER}

echo "DONE! You can now use 'glb' command (bash version)"
echo "Note: For Python version, use the original import.sh script"