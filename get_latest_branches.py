import argparse
import git
import time
from functools import partial
from operator import itemgetter
from termcolor import colored


def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument("--number", "-n", dest='chosen_number', type=int, default=5,
                        help="The number of branches you wish to display")
    return parser.parse_args()


def get_branches(chosen_number):
    bold = partial(colored, attrs=['bold'])
    repo = git.Repo(search_parent_directories=True)
    cur_branch = repo.active_branch.name
    print("""###############################################
### Welcome to your friendly git checkouter ###
###############################################
    
    You are currently working on {}""".format(bold(cur_branch, 'blue')))
    print("\nLatest {} branches you worked on:\n".format(chosen_number))
    all_branches_with_dates = []
    for ref in repo.refs:
        branch_name = ref.name
        if ref.path.startswith('refs/heads/'):
            committed_time = time.strftime('%Y-%m-%dT%H:%M:%S', time.localtime(ref.object.committed_date))

            all_branches_with_dates.append((branch_name, committed_time))
    all_branches_with_dates.sort(key=itemgetter(1), reverse=True)
    branches_names = [i[0] for i in all_branches_with_dates]
    latest_branches = branches_names[0:chosen_number]
    latest_branches.insert(0, None) # number the branches starting from 1 instead of 0
    for index, item in enumerate(latest_branches):
        if index > 0: print("[%d] - %s" % (index, item))
    chosen_branch_number = (int(input("\nYour desired branch would be?  ")))-1
    chosen_branch = branches_names[chosen_branch_number]
    try:
        repo.git.checkout(chosen_branch)
        if repo.active_branch.name == chosen_branch:
                print("\nCheckedout\checkouted successfully to {}".format(chosen_branch))

    except git.exc.GitCommandError as e:
        print("Can't checkout due to {}".format(bold(e.stderr, 'red')))


if __name__ == "__main__":
    args = parse_args()
    get_branches(args.chosen_number)
