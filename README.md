# GLB - Get latest branches
Glb is available in both Python and Bash versions that will list the latest git branches you worked on and checkout to your chosen branch.

**Python version**: Full-featured implementation using GitPython  
**Bash version**: Pure bash implementation with identical functionality (no Python dependencies)

Default number of branches is 5.

Repo path (.git) will be taken from the location you run the script from

## New: Branch Filtering
GLB now supports filtering branches to make branch selection more efficient:

- **Name filtering**: Filter branches by name patterns using wildcards
- **Date filtering**: Filter branches by last commit date

# Installation

## Python Version
Use the `import.sh` script to install the Python requirements and source the script as `glb`.

You can change the location of the script installation with first argument of the script,
and change the source profile with second argument
`./import.sh /home/ubuntu/scripts ~/.bashrc`

## Bash Version  
Use the `import_bash.sh` script to install the bash version without Python dependencies:

`./import_bash.sh [install_path] [profile_path]`

For example:
`./import_bash.sh /home/ubuntu/scripts ~/.bashrc`

# Requirements

## Python Version
`pip install GitPython`
`pip install termcolor`

## Bash Version
- Pure bash (version 4.0+ recommended)
- git command line tools
- Standard Unix utilities (date, sort, etc.)

# Usage

Both versions have identical command line interface:

## Python Version
`python3 get_latest_branches.py`

## Bash Version
`bash get_latest_branches.sh`

Or if installed via import scripts:
`glb`


A list of the latest branches will be printed and you'll be prompted to choose the branch you would like to checkout to

If you want to see more branches, you can simply specify the number as a positional argument:

## Python Version Examples
`python3 get_latest_branches.py 8`

You can also use the traditional `-n` or `--number` flags:

`python3 get_latest_branches.py -n 8`

`python3 get_latest_branches.py --number 10`

## Bash Version Examples  
`bash get_latest_branches.sh 8`

`bash get_latest_branches.sh -n 8`

`bash get_latest_branches.sh --number 10`

## Quick Switch to Previous Branch

Switch directly to the previous branch without the interactive menu:

**Python**: `python3 get_latest_branches.py --previous`

**Bash**: `bash get_latest_branches.sh --previous`

Both versions support: `glb -p` (if installed via import scripts)

This is equivalent to `git checkout -` and useful when switching between two branches frequently.

## Filtering Options

### Filter by branch name pattern:
**Python**: `python3 get_latest_branches.py --filter-name "feature/*"`

**Bash**: `bash get_latest_branches.sh --filter-name "feature/*"`

**Installed**: `glb --filter-name "hotfix/*"`

**Examples**:
`glb --filter-name "*bugfix*"`

### Filter by last commit date:
**Examples**:
`glb --filter-date "week"`

`glb --filter-date "month"`

`glb --filter-date "7d"`

`glb --filter-date "30d"`

### Combine filters:
**Examples**:
`glb 10 --filter-name "feature/*" --filter-date "week"`

## Python vs Bash Version

Both versions provide identical functionality and command-line interface, but have different dependencies and characteristics:

### Python Version
- **Pros**: More robust error handling, relies on GitPython library for git operations
- **Cons**: Requires Python 3.7+ and GitPython/termcolor packages
- **Best for**: Environments where Python is already available

### Bash Version  
- **Pros**: No Python dependencies, uses only standard Unix tools and git CLI
- **Cons**: Requires bash 4.0+ and standard Unix utilities
- **Best for**: Minimal environments, CI/CD systems, or when avoiding Python dependencies

Both versions have been tested to provide identical output and behavior.



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
