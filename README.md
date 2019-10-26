# GLB - Get latest branches
Glb is a simple python script that will list you the latest git branches you worked on and will checkout to your chosen branch.

Default number of branches is 5.

Repo path (.git) will be taken from the location you run the script from

# Requirements
`pip install GitPython`

# Usage
`python3 get_latest_branches.py`


A list of the latest branches will be printed and you'll be prompted to choose the branch you would like to checkout to

If you want to see more branches,  add `-n` or `--number` following the number of branches you would like to see

`python3 get_latest_branches.py -n 8`

`python3 get_latest_branches.py --number 10`
