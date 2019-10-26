#!/bin/bash
#
# Created By: ellacarmon
# Github: github.com/ellacarmon
# License: MIT
# CopyWrite: 2019
#
echo "#############################"
echo "## Welcome to glb for mac  ##"
echo "#############################"
echo ""
echo "First argument will be the path to install the glb script, default is Documents folder"
echo "Second argument will be the source profile folder, deafult is ~/.profile"
echo ""
echo "Installing GitPython package"
pip install GitPython

PATH_TO_INSTALL=$HOME/Documents/

if [[ -n $1 ]]
    then
        PATH_TO_INSTALL=$1
fi

echo "The path of the script is ${PATH_TO_INSTALL}"
echo ""
echo "Cloning script to ${PATH_TO_INSTALL}"
cd ${PATH_TO_INSTALL}
curl -O https://github.com/ellacarmon/buffer/blob/master/get_latest_branches.py
SOURCE_FOLDER=~/.profile
if [[ -n $2 ]]
    then
        SOURCE_FOLDER=$2
fi

echo "source folder is ${SOURCE_FOLDER}"
echo "adding glb alias"
echo 'alias glb="python3 $PATH_TO_INSTALLget_latest_branches.py"' >> ${SOURCE_FOLDER}

source ${SOURCE_FOLDER}


echo "DONE!"