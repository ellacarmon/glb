import argparse
import git
import time
import fnmatch
import datetime
from functools import partial
from operator import itemgetter
from termcolor import colored


def get_previous_branch():
    """Get the previous branch from git reflog."""
    try:
        repo = git.Repo(search_parent_directories=True)
        
        # Use git command directly to get reflog with checkout messages
        reflog_output = repo.git.reflog('--grep-reflog=checkout', '--format=%gs', '-n', '10')
        
        if not reflog_output:
            return None
            
        # Split lines and find the first checkout message
        lines = reflog_output.strip().split('\n')
        
        for line in lines:
            if 'checkout: moving from' in line:
                # Extract the previous branch name from the message
                # Message format: "checkout: moving from <from_branch> to <to_branch>"
                parts = line.split(' ')
                if len(parts) >= 4:
                    previous_branch = parts[3]  # The "from" branch
                    return previous_branch
        
        return None
    except Exception:
        return None


def checkout_previous_branch():
    """Switch to the previous branch."""
    bold = partial(colored, attrs=['bold'])
    repo = git.Repo(search_parent_directories=True)
    
    previous_branch = get_previous_branch()
    
    if not previous_branch:
        print("No previous branch found in git history.")
        return False
    
    current_branch = repo.active_branch.name
    
    if previous_branch == current_branch:
        print("Previous branch is the same as current branch ({})".format(bold(current_branch, 'yellow')))
        return False
    
    try:
        repo.git.checkout(previous_branch)
        if repo.active_branch.name == previous_branch:
            print("Successfully switched from {} to {}".format(bold(current_branch, 'blue), bold(previous_branch, 'green')))
            return True
    except git.exc.GitCommandError as e:
        print("Can't checkout due to {}".format(bold(str(e.stderr), 'red')))
        return False
    
    return False


def parse_date_filter(date_filter):
    """Parse date filter string and return datetime threshold."""
    if not date_filter:
        return None
    
    now = datetime.datetime.now()
    
    # Convert common shortcuts
    if date_filter.lower() == 'week' or date_filter == '7d':
        return now - datetime.timedelta(days=7)
    elif date_filter.lower() == 'month' or date_filter == '30d':
        return now - datetime.timedelta(days=30)
    elif date_filter.endswith('d'):
        try:
            days = int(date_filter[:-1])
            return now - datetime.timedelta(days=days)
        except ValueError:
            print(f"Invalid date filter: {date_filter}")
            return None
    elif date_filter.endswith('w'):
        try:
            weeks = int(date_filter[:-1])
            return now - datetime.timedelta(weeks=weeks)
        except ValueError:
            print(f"Invalid date filter: {date_filter}")
            return None
    else:
        print(f"Invalid date filter: {date_filter}. Use 'week', 'month', '7d', '30d', etc.")
        return None


def filter_branches(branches_with_dates, name_filter=None, date_filter=None):
    """Apply name and date filters to branches list."""
    filtered_branches = branches_with_dates
    
    # Apply name filter
    if name_filter:
        filtered_branches = [
            (branch, date) for branch, date in filtered_branches
            if fnmatch.fnmatch(branch, name_filter)
        ]
    
    # Apply date filter
    if date_filter:
        date_threshold = parse_date_filter(date_filter)
        if date_threshold:
            filtered_branches = [
                (branch, date) for branch, date in filtered_branches
                if datetime.datetime.strptime(date, '%Y-%m-%dT%H:%M:%S') >= date_threshold
            ]
    
    return filtered_branches


def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument("--number", "-n", dest='chosen_number', type=int, default=5,
                        help="The number of branches you wish to display")
    parser.add_argument("--filter-name", "-f", dest='name_filter', type=str,
                        help="Filter branches by name pattern (supports wildcards)")
    parser.add_argument("--filter-date", "-d", dest='date_filter', type=str,
                        help="Filter branches by last commit date (e.g., 'week', 'month', '7d', '30d')")
    parser.add_argument("--previous", "-p", dest='previous', action='store_true',
                        help="Switch to the previous branch (equivalent to 'git checkout -')")
    return parser.parse_args()


def get_branches(chosen_number, name_filter=None, date_filter=None):
    bold = partial(colored, attrs=['bold'])
    repo = git.Repo(search_parent_directories=True)
    cur_branch = repo.active_branch.name
    print("""###############################################
### Welcome to your friendly git checkouter ###
###############################################
    
    You are currently working on {}""".format(bold(cur_branch, 'blue')))
    
    all_branches_with_dates = []
    for ref in repo.refs:  # going over all branches and listing their names and modified date
        branch_name = ref.name
        if ref.path.startswith('refs/heads/'):  # adding only branches with heads
            # converting from epoch time
            committed_time = time.strftime('%Y-%m-%dT%H:%M:%S', time.localtime(ref.object.committed_date))
            all_branches_with_dates.append((branch_name, committed_time))

    # Apply filters
    filtered_branches = filter_branches(all_branches_with_dates, name_filter, date_filter)
    
    # Display filter information
    filter_info = []
    if name_filter:
        filter_info.append(f"name matching '{name_filter}'")
    if date_filter:
        filter_info.append(f"modified within {date_filter}")
    
    if filter_info:
        print(f"\nFiltering branches by: {' and '.join(filter_info)}")
        print(f"Found {len(filtered_branches)} matching branch(es)")
    
    if not filtered_branches:
        print("\nNo branches match the specified filters.")
        return
    
    # Sort and limit results
    filtered_branches.sort(key=itemgetter(1), reverse=True)  # Sorting all branches by date
    branches_names = [i[0] for i in filtered_branches]   # Creating a list of latest branches names
    latest_branches = branches_names[0:chosen_number]
    
    print(f"\nLatest {min(chosen_number, len(latest_branches))} branches you worked on:\n")
    
    latest_branches.insert(0, None)  # number the branches starting from 1 instead of 0
    for index, item in enumerate(latest_branches):
        if index > 0: print("[%d] - %s" % (index, item))
    chosen_branch_number = (int(input("\nYour desired branch would be?  ")))-1
    chosen_branch = branches_names[chosen_branch_number]
    if chosen_branch == repo.active_branch.name:
        print("\nYou are already working on {}".format(bold(chosen_branch, 'red')))
    try:
        repo.git.checkout(chosen_branch)
        if repo.active_branch.name == chosen_branch:
                print("\nCheckedout successfully to {}".format(chosen_branch))

    except git.exc.GitCommandError as e:
        print("Can't checkout due to {}".format(bold(e.stderr, 'red')))


if __name__ == "__main__":
    args = parse_args()
    
    # Handle previous branch flag
    if args.previous:
        checkout_previous_branch()
    else:
        get_branches(args.chosen_number, args.name_filter, args.date_filter)
