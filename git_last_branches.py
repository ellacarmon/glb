from operator import itemgetter
import time
import git


def get_branches():
    repo = git.Repo(search_parent_directories=True)
    cur_branch = repo.active_branch.name
    print("""#######################################
### Welcome to your friendly git checkouter ###
###############################################
    
    You are currently on {}""".format(cur_branch))
    number_of_branches = int(input("How many branches would you like to see? "))
    print("Latest {} branches you worked on:".format(number_of_branches))
    bla = []
    for ref in repo.refs:
        branch_name = ref.name
        if ref.path.startswith('refs/heads/'):
            commited_time = time.strftime('%Y-%m-%dT%H:%M:%S', time.localtime(ref.object.committed_date))

            bla.append((branch_name, commited_time))
    bla.sort(key=itemgetter(1), reverse=True)
    branches = [i[0] for i in bla]
    latest_branches = branches[0:number_of_branches]
    for item in latest_branches:
        print(latest_branches.index(item), item)
    chosen_branch_number = int(input("Your desired branch would be?  "))
    git2 = repo.git
    chosen_branch = branches[chosen_branch_number]
    git2.checkout(chosen_branch)
    if repo.active_branch.name == chosen_branch:
        print("Checkedout\checkouted successfully to {}".format(chosen_branch))
    else:
        print("sorry, some problems mate...")


if __name__ == "__main__":
    get_branches()

