# GLB - Get latest branches
Glb is a simple python script that will list you the latest git branches you worked on and will checkout to your chosen branch.

Default number of branches is 5.

Repo path (.git) will be taken from the location you run the script from

## New: Branch Filtering
GLB now supports filtering branches to make branch selection more efficient:

- **Name filtering**: Filter branches by name patterns using wildcards
- **Date filtering**: Filter branches by last commit date

# Installation
Use the `import.sh` script to install the requirements and source the script as `glb`.

You can change the location of the script installation with first argument of the script,
and change the source profile with second argument
`./import.sh /home/ubuntu/scripts ~/.bashrc`

# Requirements
`pip install GitPython`
`pip install termcolor`

# Usage
`python3 get_latest_branches.py`


A list of the latest branches will be printed and you'll be prompted to choose the branch you would like to checkout to

If you want to see more branches, you can simply specify the number as a positional argument:

`python3 get_latest_branches.py 8`

You can also use the traditional `-n` or `--number` flags:

`python3 get_latest_branches.py -n 8`

`python3 get_latest_branches.py --number 10`

## Quick Switch to Previous Branch

Switch directly to the previous branch without the interactive menu:

`python3 get_latest_branches.py --previous`

`python3 get_latest_branches.py -p`

This is equivalent to `git checkout -` and useful when switching between two branches frequently.

## Filtering Options

### Filter by branch name pattern:
`python3 get_latest_branches.py --filter-name "feature/*"`

`python3 get_latest_branches.py --filter-name "hotfix/*"`

`python3 get_latest_branches.py --filter-name "*bugfix*"`

### Filter by last commit date:
`python3 get_latest_branches.py --filter-date "week"`

`python3 get_latest_branches.py --filter-date "month"`

`python3 get_latest_branches.py --filter-date "7d"`

`python3 get_latest_branches.py --filter-date "30d"`

### Combine filters:
`python3 get_latest_branches.py 10 --filter-name "feature/*" --filter-date "week"`



```
» glb 3               
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
