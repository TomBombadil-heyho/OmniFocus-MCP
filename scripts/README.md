# Repository Maintenance Scripts

This directory contains scripts for maintaining the repository.

## delete-non-main-branches.sh

A safe script to delete all remote branches except `main`.

### Usage

```bash
# Dry run - see what would be deleted without actually deleting
./scripts/delete-non-main-branches.sh --dry-run

# Actually delete the branches (will ask for confirmation)
./scripts/delete-non-main-branches.sh

# Show help
./scripts/delete-non-main-branches.sh --help
```

### Features

- ✅ Protects the `main` branch from deletion
- ✅ Shows a preview of branches to be deleted
- ✅ Requires explicit confirmation before deletion
- ✅ Provides detailed feedback during deletion
- ✅ Colored output for better readability
- ✅ Dry-run mode for safe testing

### Safety Features

1. **Branch Protection**: The `main` branch is automatically protected and cannot be deleted
2. **Confirmation Required**: You must type "yes" to confirm before any branches are deleted
3. **Dry Run Mode**: Use `--dry-run` to see what would happen without making changes
4. **Clear Output**: Color-coded output shows exactly what's happening

### Example Output

```
Branch Cleanup Script
================================

Fetching latest remote information...

Protected branch: main

The following branches will be deleted:
========================================
  ✗ feature-branch-1
  ✗ old-experiment
  ✗ copilot/delete-non-main-branches

Total branches to delete: 3

Are you sure you want to delete these 3 branch(es)?
Type 'yes' to confirm: yes

Deleting branches...
====================
Deleting feature-branch-1... ✓
Deleting old-experiment... ✓
Deleting copilot/delete-non-main-branches... ✓

Summary:
========
Deleted: 3

Branch cleanup complete!
```

### When to Use

Use this script to clean up old branches when:
- You have many stale feature branches
- You want to simplify your repository
- You're consolidating development into the main branch
- You need to clean up after a major refactor or reorganization

### Before Running

Consider:
1. Checking if any branches have unmerged work you want to keep
2. Protecting the `main` branch via GitHub settings to prevent accidental force pushes
3. Communicating with your team if this is a shared repository

### Additional Manual Steps (from original issue)

After running this script, you may want to:

1. **Protect the main branch** via GitHub web interface:
   - Go to Settings > Branches
   - Add a branch protection rule for `main`
   - Enable options like "Require pull request reviews" and "Require status checks"

2. **Resynchronize local repository**:
   ```bash
   git fetch --prune
   git checkout main
   git pull origin main
   ```

3. **Clean up local branches** (if needed):
   ```bash
   git branch -vv | grep ': gone]' | awk '{print $1}' | xargs git branch -d
   ```
