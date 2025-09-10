# GLB - Get Latest Branches Tool

GLB is a Python-based command-line tool that helps developers quickly list and checkout recent git branches. It supports filtering by name patterns and commit dates.

**ALWAYS reference these instructions first and fallback to search or bash commands only when you encounter unexpected information that does not match the info here.**

## Working Effectively

### Prerequisites and Dependencies
- Ensure Python 3.7+ is installed: `python3 --version`
- Install Python package manager: Verify pip is available with `pip --version`
- **NEVER CANCEL**: Install Python dependencies with `pip install -r requirements.txt` -- takes ~5 seconds to complete

### Core Development Workflow
1. **Install dependencies**: `pip install -r requirements.txt`
2. **Test the tool**: `python3 get_latest_branches.py --help` -- takes <1 second
3. **Validate core functionality**: Test with `timeout 5 python3 get_latest_branches.py -n 1` to see branch listing (will timeout after showing branches, which is expected)

### Installation for Daily Use
- **Manual installation**: Use the provided `import.sh` script, but NOTE: this script clones the repository and modifies shell profiles
- **Alternative installation**: Copy `get_latest_branches.py` to desired location and create alias manually
- The script installs GitPython dependency and creates a `glb` alias in shell profile

## Validation and Testing

### Manual Validation Scenarios
After making any changes to the code, ALWAYS validate these scenarios:

1. **Basic functionality**: Run `python3 get_latest_branches.py --help` to verify no syntax errors
2. **Branch listing**: Use `timeout 5 python3 get_latest_branches.py -n 3` to see recent branches (timeout is expected)
3. **Filtering by name**: Test with `timeout 5 python3 get_latest_branches.py --filter-name "test*" -n 2`
4. **Filtering by date**: Test with `timeout 5 python3 get_latest_branches.py --filter-date "week" -n 2`
5. **Combined filters**: Test with `timeout 5 python3 get_latest_branches.py --filter-name "feature/*" --filter-date "month" -n 5`

### Expected Behavior
- Script shows current branch in blue
- Lists branches sorted by most recent commit date
- Interactive prompt asks for branch selection (number input)
- Successfully switches to selected branch
- Handles git checkout errors gracefully

### Timing Expectations
- Dependency installation: ~5 seconds
- Script startup and help: <1 second  
- Branch analysis and display: <1 second for typical repositories
- **NEVER CANCEL** any operations - they complete quickly

## Code Structure and Navigation

### Key Files
- `get_latest_branches.py` - Main script (138 lines) containing all functionality
- `import.sh` - Installation script for setting up the tool system-wide
- `requirements.txt` - Python dependencies (GitPython==3.1.37, termcolor==1.1.0)
- `README.md` - User documentation with examples and usage patterns

### Main Script Structure
- **Lines 1-40**: Date parsing and filtering utilities
- **Lines 41-73**: Command line argument parsing and branch filtering logic  
- **Lines 74-138**: Main branch retrieval, display, and checkout functionality

### Important Functions
- `parse_date_filter()` - Converts date strings like "week", "month", "7d" to datetime objects
- `filter_branches()` - Applies name and date filters to branch lists
- `get_branches()` - Main function that lists branches and handles user interaction

## Common Development Tasks

### Testing Changes
1. **Syntax validation**: `python3 -m py_compile get_latest_branches.py`
2. **Import testing**: `python3 -c "import get_latest_branches; print('Import successful')"`
3. **Function testing**: Create test branches and verify filtering works correctly
4. **Git integration**: Ensure script works in different git repository contexts

### Adding New Features
- **Name filtering**: Modify `filter_branches()` function for new pattern types
- **Date filtering**: Extend `parse_date_filter()` for new date formats  
- **Display options**: Update the branch listing section in `get_branches()`
- **Command line options**: Add new arguments in `parse_args()` function

### No Build Process
- This is a pure Python script with no compilation step
- No CI/CD pipeline exists currently
- No testing framework is set up
- Changes can be tested immediately after editing

## Repository Context

### Git Repository State
- Repository contains only the tool files, no complex project structure
- Testing requires having git branches to work with
- Script uses GitPython library to interact with git repository
- Works from any directory within a git repository (searches parent directories)

### Dependencies
- **GitPython** (3.1.37): Git repository interaction library
- **termcolor** (1.1.0): Console text coloring for better UX
- Both are specified in `requirements.txt` with exact versions

### Installation Script Behavior
- `import.sh` clones the repository to specified path (default: $HOME/)
- Copies main script to installation directory
- Adds alias to shell profile (.zshrc by default, customizable)
- Designed for macOS but works on Linux systems

## Troubleshooting

### Common Issues
- **GitCommandError**: Usually indicates git checkout conflicts or invalid branch names
- **Repository not found**: Script must be run from within a git repository
- **Import errors**: Verify dependencies are installed with `pip show GitPython termcolor`
- **Permission errors**: May need user pip installation (`--user` flag automatically used)

### Validation Commands
Always run these before completing changes:
- `python3 get_latest_branches.py --help` - Verify script syntax
- `python3 -c "import get_latest_branches"` - Test imports
- Test in a repository with multiple branches for full validation

### Performance Notes
- Script performance depends on number of branches in repository
- Large repositories (100+ branches) still complete in under 1 second
- Date filtering is performed in memory after branch retrieval
- No external network calls required (works offline)