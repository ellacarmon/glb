# GLB - Get latest branches
Glb is a simple python script that will list you the latest git branches you worked on and will checkout to your chosen branch.

Default number of branches is 5.

Repo path (.git) will be taken from the location you run the script from

# Installation
Use the `import.sh` script to install the requirements and source the script as `glb`.

You can change the location of the script installation with first argument of the script,
and change the source profile with second argument
`./import.sh /home/ubuntu/scripts ~/.bashrc`

# Requirements
`pip install GitPython`

# Usage
`python3 get_latest_branches.py`


A list of the latest branches will be printed and you'll be prompted to choose the branch you would like to checkout to

If you want to see more branches,  add `-n` or `--number` following the number of branches you would like to see

`python3 get_latest_branches.py -n 8`

`python3 get_latest_branches.py --number 10`



```
» glb -n 3               
###############################################
### Welcome to your friendly git checkouter ###
###############################################
    
    You are currently working on master

Latest 3 branches you worked on:

[1] - another_example_branch
[2] - example_branch
[3] - master

Your desired branch would be?  2

Checkedout\checkouted successfully to example_branch
```
