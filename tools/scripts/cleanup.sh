#!/bin/bash

# QuizzTok Development Environment Cleanup Script
# Stops services and cleans up development data

set -e

echo "🧹 Cleaning up QuizzTok Development Environment..."
echo "================================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to ask for confirmation
confirm() {
    read -p "$(echo -e ${YELLOW}[CONFIRM]${NC} $1 [y/N]: )" -n 1 -r
    echo
    [[ $REPLY =~ ^[Yy]$ ]]
}

# Stop Docker services
stop_docker_services() {
    print_status "Stopping Docker services..."

    if docker-compose ps | grep -q "Up"; then
        docker-compose down
        print_success "Docker services stopped"
    else
        print_warning "No running Docker services found"
    fi
}

# Clean Docker volumes
clean_docker_volumes() {
    if confirm "Remove Docker volumes (this will delete all database data)?"; then
        print_status "Removing Docker volumes..."

        docker-compose down -v 2>/dev/null || true
        docker volume prune -f

        print_success "Docker volumes cleaned"
    else
        print_status "Skipping Docker volume cleanup"
    fi
}

# Clean Docker images
clean_docker_images() {
    if confirm "Remove Docker images?"; then
        print_status "Removing Docker images..."

        # Remove project-specific images
        docker images | grep quizztok | awk '{print $3}' | xargs -r docker rmi -f

        # Clean up dangling images
        docker image prune -f

        print_success "Docker images cleaned"
    else
        print_status "Skipping Docker image cleanup"
    fi
}

# Clean node_modules
clean_node_modules() {
    if confirm "Remove node_modules directories?"; then
        print_status "Removing node_modules..."

        find . -name "node_modules" -type d -exec rm -rf {} + 2>/dev/null || true

        print_success "node_modules cleaned"
    else
        print_status "Skipping node_modules cleanup"
    fi
}

# Clean build artifacts
clean_build_artifacts() {
    if confirm "Remove build artifacts (.next, dist, coverage)?"; then
        print_status "Removing build artifacts..."

        # Next.js build files
        find . -name ".next" -type d -exec rm -rf {} + 2>/dev/null || true

        # General build directories
        find . -name "dist" -type d -exec rm -rf {} + 2>/dev/null || true
        find . -name "build" -type d -exec rm -rf {} + 2>/dev/null || true

        # Coverage reports
        find . -name "coverage" -type d -exec rm -rf {} + 2>/dev/null || true
        find . -name ".nyc_output" -type d -exec rm -rf {} + 2>/dev/null || true

        print_success "Build artifacts cleaned"
    else
        print_status "Skipping build artifacts cleanup"
    fi
}

# Clean environment files
clean_env_files() {
    if confirm "Remove environment files (.env, .env.local)?"; then
        print_status "Removing environment files..."

        rm -f .env
        rm -f apps/api/.env
        rm -f apps/web/.env.local

        print_success "Environment files cleaned"
    else
        print_status "Skipping environment files cleanup"
    fi
}

# Clean logs
clean_logs() {
    if confirm "Remove log files?"; then
        print_status "Removing log files..."

        find . -name "*.log" -type f -delete 2>/dev/null || true
        find . -name "logs" -type d -exec rm -rf {} + 2>/dev/null || true

        print_success "Log files cleaned"
    else
        print_status "Skipping log cleanup"
    fi
}

# Clean Playwright browsers
clean_playwright() {
    if confirm "Remove Playwright browsers?"; then
        print_status "Removing Playwright browsers..."

        rm -rf tools/mcp-config/playwright-browsers

        print_success "Playwright browsers cleaned"
    else
        print_status "Skipping Playwright cleanup"
    fi
}

# Reset Git to clean state
reset_git() {
    if confirm "Reset Git to clean state (WARNING: This will remove all uncommitted changes)?"; then
        print_warning "This will permanently delete all uncommitted changes!"
        if confirm "Are you absolutely sure?"; then
            print_status "Resetting Git repository..."

            git reset --hard HEAD
            git clean -fd

            print_success "Git repository reset to clean state"
        else
            print_status "Skipping Git reset"
        fi
    else
        print_status "Skipping Git reset"
    fi
}

# Show cleanup options
show_menu() {
    echo ""
    echo "Select cleanup options:"
    echo "1. Quick cleanup (stop services, clean builds)"
    echo "2. Full cleanup (everything except data)"
    echo "3. Nuclear cleanup (everything including data)"
    echo "4. Custom cleanup (choose what to clean)"
    echo "5. Exit"
    echo ""
}

# Quick cleanup
quick_cleanup() {
    print_status "Running quick cleanup..."
    stop_docker_services
    clean_build_artifacts
    clean_logs
    print_success "Quick cleanup completed!"
}

# Full cleanup
full_cleanup() {
    print_status "Running full cleanup..."
    stop_docker_services
    clean_docker_images
    clean_node_modules
    clean_build_artifacts
    clean_logs
    clean_playwright
    print_success "Full cleanup completed!"
}

# Nuclear cleanup
nuclear_cleanup() {
    print_warning "Nuclear cleanup will remove EVERYTHING including database data!"
    if confirm "Are you sure you want to proceed?"; then
        print_status "Running nuclear cleanup..."
        stop_docker_services
        clean_docker_volumes
        clean_docker_images
        clean_node_modules
        clean_build_artifacts
        clean_env_files
        clean_logs
        clean_playwright
        reset_git
        print_success "Nuclear cleanup completed!"
    else
        print_status "Nuclear cleanup cancelled"
    fi
}

# Custom cleanup
custom_cleanup() {
    print_status "Custom cleanup options:"

    stop_docker_services

    clean_docker_volumes
    clean_docker_images
    clean_node_modules
    clean_build_artifacts
    clean_env_files
    clean_logs
    clean_playwright
    reset_git

    print_success "Custom cleanup completed!"
}

# Main menu
main() {
    while true; do
        show_menu
        read -p "Enter your choice (1-5): " choice

        case $choice in
            1)
                quick_cleanup
                break
                ;;
            2)
                full_cleanup
                break
                ;;
            3)
                nuclear_cleanup
                break
                ;;
            4)
                custom_cleanup
                break
                ;;
            5)
                print_status "Exiting cleanup script"
                exit 0
                ;;
            *)
                print_error "Invalid option. Please choose 1-5."
                ;;
        esac
    done

    echo ""
    print_success "🎉 Cleanup completed!"
    echo ""
    print_status "To set up the environment again, run:"
    echo "  ./tools/scripts/setup-dev-environment.sh"
    echo ""
}

# Run main function
main "$@"