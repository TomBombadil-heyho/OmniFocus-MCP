#!/bin/bash

# Script to delete all remote branches except 'main'
# This script provides a safe way to clean up old branches

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
PROTECTED_BRANCH="main"
DRY_RUN=false

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --help)
            echo "Usage: $0 [--dry-run] [--help]"
            echo ""
            echo "Options:"
            echo "  --dry-run    Show what would be deleted without actually deleting"
            echo "  --help       Show this help message"
            echo ""
            echo "This script deletes all remote branches except 'main'."
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

echo -e "${GREEN}Branch Cleanup Script${NC}"
echo "================================"
echo ""

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo -e "${RED}Error: Not in a git repository${NC}"
    exit 1
fi

# Check if origin remote exists
if ! git remote get-url origin > /dev/null 2>&1; then
    echo -e "${RED}Error: 'origin' remote not found${NC}"
    exit 1
fi

# Get all remote branches directly from origin
echo "Fetching remote branch list..."
all_remote_branches=$(git ls-remote --heads origin 2>&1)

if [ $? -ne 0 ]; then
    echo -e "${RED}Error: Failed to fetch remote branches from origin${NC}"
    exit 1
fi

# Extract branch names
all_remote_branches=$(echo "$all_remote_branches" | awk '{gsub(/^refs\/heads\//, "", $2); print $2}')

echo ""
echo -e "${YELLOW}Protected branch: ${PROTECTED_BRANCH}${NC}"
echo ""

# Filter out the protected branch and store in array
mapfile -t branches_array < <(echo "$all_remote_branches" | grep -v "^${PROTECTED_BRANCH}$" | grep -v "^$" || true)

# Check if array has any non-empty elements
if [ ${#branches_array[@]} -eq 0 ] || { [ ${#branches_array[@]} -eq 1 ] && [ -z "${branches_array[0]}" ]; }; then
    echo -e "${GREEN}No branches to delete. Only '${PROTECTED_BRANCH}' exists.${NC}"
    exit 0
fi

# Display branches that will be deleted
echo "The following branches will be deleted:"
echo "========================================"
for branch in "${branches_array[@]}"; do
    echo -e "  ${RED}✗${NC} $branch"
done
echo ""

# Count branches
branch_count=${#branches_array[@]}
echo "Total branches to delete: $branch_count"
echo ""

if [ "$DRY_RUN" = true ]; then
    echo -e "${YELLOW}DRY RUN MODE - No branches will be deleted${NC}"
    echo "To actually delete these branches, run without --dry-run flag"
    exit 0
fi

# Ask for confirmation
echo -e "${YELLOW}Are you sure you want to delete these $branch_count branch(es)?${NC}"
read -p "Type 'yes' to confirm: " confirmation

if [ "$confirmation" != "yes" ]; then
    echo -e "${RED}Deletion cancelled${NC}"
    exit 0
fi

echo ""
echo "Deleting branches..."
echo "===================="

# Delete each branch
deleted_count=0
failed_count=0

for branch in "${branches_array[@]}"; do
    echo -n "Deleting $branch... "
    if git push origin --delete "$branch" > /dev/null 2>&1; then
        echo -e "${GREEN}✓${NC}"
        deleted_count=$((deleted_count + 1))
    else
        echo -e "${RED}✗ Failed${NC}"
        failed_count=$((failed_count + 1))
    fi
done

echo ""
echo "Summary:"
echo "========"
echo -e "${GREEN}Deleted: $deleted_count${NC}"
if [ $failed_count -gt 0 ]; then
    echo -e "${RED}Failed: $failed_count${NC}"
fi

echo ""
echo -e "${GREEN}Branch cleanup complete!${NC}"
