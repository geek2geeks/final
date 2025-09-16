#!/bin/bash

# QuizzTok Worktree Setup Script
# This script sets up Git worktrees for parallel BMAD agent development

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to create a worktree
create_worktree() {
    local branch_name="$1"
    local feature_description="$2"
    local worktree_path="../quizztok-${branch_name}"

    print_info "Creating worktree for feature: $feature_description"

    # Create the branch if it doesn't exist
    if ! git show-ref --verify --quiet "refs/heads/$branch_name"; then
        print_info "Creating new branch: $branch_name"
        git branch "$branch_name"
    fi

    # Create worktree
    if [ -d "$worktree_path" ]; then
        print_warning "Worktree directory already exists: $worktree_path"
        read -p "Do you want to remove it and recreate? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            rm -rf "$worktree_path"
        else
            print_error "Aborted."
            return 1
        fi
    fi

    git worktree add "$worktree_path" "$branch_name"

    # Copy BMAD configuration to worktree
    if [ -d ".bmad-core" ]; then
        print_info "Copying BMAD configuration to worktree..."
        cp -r .bmad-core "$worktree_path/"
    fi

    print_info "Worktree created successfully!"
    print_info "Path: $(realpath "$worktree_path")"
    print_info "Branch: $branch_name"

    # Display next steps
    echo
    print_info "Next steps:"
    echo "  1. cd $(realpath "$worktree_path")"
    echo "  2. Start your BMAD agent development"
    echo "  3. Use 'git add && git commit' to save progress"
    echo "  4. Use 'git push -u origin $branch_name' to push changes"
}

# Function to list existing worktrees
list_worktrees() {
    print_info "Existing worktrees:"
    git worktree list
}

# Function to remove a worktree
remove_worktree() {
    local worktree_path="$1"

    if [ -z "$worktree_path" ]; then
        print_error "Please specify the worktree path to remove"
        return 1
    fi

    print_warning "Removing worktree: $worktree_path"
    git worktree remove "$worktree_path"
    print_info "Worktree removed successfully!"
}

# Function to show help
show_help() {
    echo "QuizzTok Worktree Setup Script"
    echo
    echo "Usage: $0 [COMMAND] [OPTIONS]"
    echo
    echo "Commands:"
    echo "  create <branch-name> <description>  Create a new worktree"
    echo "  list                                 List existing worktrees"
    echo "  remove <path>                        Remove a worktree"
    echo "  help                                 Show this help message"
    echo
    echo "Examples:"
    echo "  $0 create feature/epic-1-auth \"Epic 1: Authentication System\""
    echo "  $0 list"
    echo "  $0 remove ../quizztok-feature-epic-1-auth"
}

# Main script logic
main() {
    cd "$ROOT_DIR"

    case "${1:-help}" in
        "create")
            if [ $# -lt 3 ]; then
                print_error "Usage: $0 create <branch-name> <description>"
                exit 1
            fi
            create_worktree "$2" "$3"
            ;;
        "list")
            list_worktrees
            ;;
        "remove")
            if [ $# -lt 2 ]; then
                print_error "Usage: $0 remove <worktree-path>"
                exit 1
            fi
            remove_worktree "$2"
            ;;
        "help"|*)
            show_help
            ;;
    esac
}

main "$@"