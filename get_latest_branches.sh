#!/bin/bash
#
# GLB - Get Latest Branches (Bash Version)
# A bash equivalent of the Python get_latest_branches.py script
#
# Created By: GitHub Copilot
# Based on original Python version by: ellacarmon
# License: MIT
#

# Color functions
bold() {
    echo -e "\033[1m$1\033[0m"
}

red() {
    echo -e "\033[1;31m$1\033[0m"
}

blue() {
    echo -e "\033[1;34m$1\033[0m"
}

green() {
    echo -e "\033[1;32m$1\033[0m"
}

yellow() {
    echo -e "\033[1;33m$1\033[0m"
}

# Default values
CHOSEN_NUMBER=5
NAME_FILTER=""
DATE_FILTER=""
PREVIOUS=false

# Help function
show_help() {
    cat << EOF
usage: get_latest_branches.sh [-h] [--number CHOSEN_NUMBER] [--filter-name NAME_FILTER] [--filter-date DATE_FILTER] [--previous] [number]

positional arguments:
  number                The number of branches you wish to display

options:
  -h, --help            show this help message and exit
  --number CHOSEN_NUMBER, -n CHOSEN_NUMBER
                        The number of branches you wish to display
  --filter-name NAME_FILTER, -f NAME_FILTER
                        Filter branches by name pattern (supports wildcards)
  --filter-date DATE_FILTER, -d DATE_FILTER
                        Filter branches by last commit date (e.g., 'week', 'month', '7d', '30d')
  --previous, -p        Switch to the previous branch (equivalent to 'git checkout -')
EOF
}

# Parse command line arguments
parse_args() {
    local positional_number=""
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                exit 0
                ;;
            -n|--number)
                CHOSEN_NUMBER="$2"
                shift 2
                ;;
            -f|--filter-name)
                NAME_FILTER="$2"
                shift 2
                ;;
            -d|--filter-date)
                DATE_FILTER="$2"
                shift 2
                ;;
            -p|--previous)
                PREVIOUS=true
                shift
                ;;
            -*)
                echo "Unknown option: $1" >&2
                show_help >&2
                exit 1
                ;;
            *)
                if [[ -z "$positional_number" ]]; then
                    positional_number="$1"
                else
                    echo "Too many positional arguments" >&2
                    show_help >&2
                    exit 1
                fi
                shift
                ;;
        esac
    done
    
    # Positional argument takes precedence over flag
    if [[ -n "$positional_number" ]]; then
        CHOSEN_NUMBER="$positional_number"
    fi
    
    # Validate CHOSEN_NUMBER is a number
    if ! [[ "$CHOSEN_NUMBER" =~ ^[0-9]+$ ]]; then
        echo "Error: Number must be a positive integer" >&2
        exit 1
    fi
}

# Get previous branch from reflog
get_previous_branch() {
    local reflog_output
    reflog_output=$(git reflog --grep-reflog="checkout" --format="%gs" -n 10 2>/dev/null)
    
    if [[ -z "$reflog_output" ]]; then
        return 1
    fi
    
    local line
    while IFS= read -r line; do
        if [[ $line == *"checkout: moving from"* ]]; then
            # Extract the "from" branch name
            # Message format: "checkout: moving from <from_branch> to <to_branch>"
            local from_branch
            from_branch=$(echo "$line" | sed 's/.*moving from \([^ ]*\) to .*/\1/')
            echo "$from_branch"
            return 0
        fi
    done <<< "$reflog_output"
    
    return 1
}

# Switch to previous branch
checkout_previous_branch() {
    local previous_branch
    local current_branch
    
    current_branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
    if [[ $? -ne 0 ]]; then
        echo "Error: Not in a git repository" >&2
        return 1
    fi
    
    previous_branch=$(get_previous_branch)
    if [[ $? -ne 0 || -z "$previous_branch" ]]; then
        echo "No previous branch found in git history."
        return 1
    fi
    
    if [[ "$previous_branch" == "$current_branch" ]]; then
        echo "Previous branch is the same as current branch ($(yellow "$current_branch"))"
        return 0
    fi
    
    if git checkout "$previous_branch" 2>/dev/null; then
        local new_current
        new_current=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
        if [[ "$new_current" == "$previous_branch" ]]; then
            echo "Successfully switched from $(blue "$current_branch") to $(green "$previous_branch")"
            return 0
        fi
    else
        local error_msg
        error_msg=$(git checkout "$previous_branch" 2>&1)
        echo "Can't checkout due to $(red "$error_msg")"
        return 1
    fi
    
    return 1
}

# Parse date filter and return timestamp threshold
parse_date_filter() {
    local date_filter="$1"
    local now_timestamp
    now_timestamp=$(date +%s)
    
    case "$date_filter" in
        "week"|"7d")
            echo $((now_timestamp - 7 * 24 * 3600))
            ;;
        "month"|"30d")
            echo $((now_timestamp - 30 * 24 * 3600))
            ;;
        *d)
            local days=${date_filter%d}
            if [[ "$days" =~ ^[0-9]+$ ]]; then
                echo $((now_timestamp - days * 24 * 3600))
            else
                echo "Invalid date filter: $date_filter" >&2
                return 1
            fi
            ;;
        *w)
            local weeks=${date_filter%w}
            if [[ "$weeks" =~ ^[0-9]+$ ]]; then
                echo $((now_timestamp - weeks * 7 * 24 * 3600))
            else
                echo "Invalid date filter: $date_filter" >&2
                return 1
            fi
            ;;
        *)
            echo "Invalid date filter: $date_filter. Use 'week', 'month', '7d', '30d', etc." >&2
            return 1
            ;;
    esac
}

# Apply name filter to branch name
matches_name_filter() {
    local branch_name="$1"
    local name_filter="$2"
    
    if [[ -z "$name_filter" ]]; then
        return 0  # No filter means all match
    fi
    
    # Use bash pattern matching (similar to Python's fnmatch)
    case "$branch_name" in
        $name_filter)
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

# Main function to get and display branches
get_branches() {
    local current_branch
    current_branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
    
    if [[ $? -ne 0 ]]; then
        echo "Error: Not in a git repository" >&2
        exit 1
    fi
    
    echo "###############################################"
    echo "### Welcome to your friendly git checkouter ###"
    echo "###############################################"
    echo ""
    echo "    You are currently working on $(blue "$current_branch")"
    
    # Get all branches with their commit timestamps
    local all_branches_data
    all_branches_data=$(git for-each-ref --format='%(refname:short)|%(committerdate:unix)' refs/heads/ 2>/dev/null)
    
    if [[ -z "$all_branches_data" ]]; then
        echo "No branches found" >&2
        exit 1
    fi
    
    # Apply filters
    local filtered_branches=()
    local date_threshold=""
    
    if [[ -n "$DATE_FILTER" ]]; then
        date_threshold=$(parse_date_filter "$DATE_FILTER")
        if [[ $? -ne 0 ]]; then
            exit 1
        fi
    fi
    
    while IFS='|' read -r branch_name commit_timestamp; do
        # Apply name filter
        if ! matches_name_filter "$branch_name" "$NAME_FILTER"; then
            continue
        fi
        
        # Apply date filter
        if [[ -n "$date_threshold" && "$commit_timestamp" -lt "$date_threshold" ]]; then
            continue
        fi
        
        filtered_branches+=("$commit_timestamp|$branch_name")
    done <<< "$all_branches_data"
    
    # Display filter information
    local filter_info=""
    if [[ -n "$NAME_FILTER" ]]; then
        filter_info="name matching '$NAME_FILTER'"
    fi
    if [[ -n "$DATE_FILTER" ]]; then
        if [[ -n "$filter_info" ]]; then
            filter_info="$filter_info and modified within $DATE_FILTER"
        else
            filter_info="modified within $DATE_FILTER"
        fi
    fi
    
    if [[ -n "$filter_info" ]]; then
        echo ""
        echo "Filtering branches by: $filter_info"
        echo "Found ${#filtered_branches[@]} matching branch(es)"
    fi
    
    if [[ ${#filtered_branches[@]} -eq 0 ]]; then
        echo ""
        echo "No branches match the specified filters."
        return 1
    fi
    
    # Sort branches by timestamp (newest first)
    IFS=$'\n' sorted_branches=($(sort -t'|' -k1 -nr <<< "${filtered_branches[*]}"))
    
    # Extract branch names and limit to chosen number
    local latest_branches=()
    local count=0
    for entry in "${sorted_branches[@]}"; do
        if [[ $count -ge $CHOSEN_NUMBER ]]; then
            break
        fi
        local branch_name=${entry#*|}
        latest_branches+=("$branch_name")
        ((count++))
    done
    
    echo ""
    echo "Latest ${#latest_branches[@]} branches you worked on:"
    echo ""
    
    # Display numbered menu
    for i in "${!latest_branches[@]}"; do
        echo "[$((i+1))] - ${latest_branches[$i]}"
    done
    
    # Get user input
    echo ""
    read -p "Your desired branch would be?  " choice
    
    # Validate input
    if ! [[ "$choice" =~ ^[0-9]+$ ]] || [[ "$choice" -lt 1 || "$choice" -gt "${#latest_branches[@]}" ]]; then
        echo "Invalid choice: $choice" >&2
        exit 1
    fi
    
    local chosen_branch="${latest_branches[$((choice-1))]}"
    
    if [[ "$chosen_branch" == "$current_branch" ]]; then
        echo ""
        echo "You are already working on $(red "$chosen_branch")"
    fi
    
    # Always attempt checkout (matching Python behavior)
    local checkout_error
    if checkout_error=$(git checkout "$chosen_branch" 2>&1); then
        local new_current
        new_current=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
        if [[ "$new_current" == "$chosen_branch" ]]; then
            echo ""
            echo "Checkedout successfully to $chosen_branch"
        fi
    else
        echo "Can't checkout due to $(red "$checkout_error")"
        return 1
    fi
}

# Main execution
main() {
    # Check if we're in a git repository
    if ! git rev-parse --git-dir >/dev/null 2>&1; then
        echo "Error: Not in a git repository" >&2
        exit 1
    fi
    
    parse_args "$@"
    
    if [[ "$PREVIOUS" == "true" ]]; then
        checkout_previous_branch
    else
        get_branches
    fi
}

# Run main function with all arguments
main "$@"