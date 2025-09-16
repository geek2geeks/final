#!/bin/bash

# QuizzTok Development Environment Setup Script
# This script sets up the complete development environment

set -e  # Exit on any error

echo "🚀 Setting up QuizzTok Development Environment..."
echo "================================================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
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

# Check if required tools are installed
check_dependencies() {
    print_status "Checking dependencies..."

    local missing_deps=()

    if ! command -v docker &> /dev/null; then
        missing_deps+=("docker")
    fi

    if ! command -v docker-compose &> /dev/null; then
        missing_deps+=("docker-compose")
    fi

    if ! command -v pnpm &> /dev/null; then
        missing_deps+=("pnpm")
    fi

    if ! command -v node &> /dev/null; then
        missing_deps+=("node")
    fi

    if [ ${#missing_deps[@]} -ne 0 ]; then
        print_error "Missing dependencies: ${missing_deps[*]}"
        print_status "Please install the missing dependencies and run this script again."
        exit 1
    fi

    print_success "All dependencies are installed!"
}

# Copy environment files
setup_environment_files() {
    print_status "Setting up environment files..."

    # Root environment
    if [ ! -f ".env" ]; then
        cp .env.example .env
        print_success "Created root .env file"
    else
        print_warning "Root .env file already exists, skipping..."
    fi

    # API environment
    if [ ! -f "apps/api/.env" ]; then
        cp apps/api/.env.example apps/api/.env
        print_success "Created API .env file"
    else
        print_warning "API .env file already exists, skipping..."
    fi

    # Web environment
    if [ ! -f "apps/web/.env.local" ]; then
        cp apps/web/.env.example apps/web/.env.local
        print_success "Created Web .env.local file"
    else
        print_warning "Web .env.local file already exists, skipping..."
    fi
}

# Install dependencies
install_dependencies() {
    print_status "Installing dependencies..."

    pnpm install --frozen-lockfile

    print_success "Dependencies installed successfully!"
}

# Setup SSL certificates
setup_ssl() {
    print_status "Setting up SSL certificates..."

    cd infrastructure/docker/nginx

    if [ -f "ssl/localhost.crt" ] && [ -f "ssl/localhost.key" ]; then
        print_warning "SSL certificates already exist, skipping..."
    else
        if [ -x "generate-ssl.sh" ]; then
            ./generate-ssl.sh
        elif [ -f "generate-ssl.ps1" ]; then
            powershell -ExecutionPolicy Bypass -File generate-ssl.ps1
        else
            print_warning "No SSL generation script found, using existing certificates"
        fi
    fi

    cd - > /dev/null
    print_success "SSL certificates ready!"
}

# Start Docker services
start_docker_services() {
    print_status "Starting Docker services..."

    # Check if Docker is running
    if ! docker info &> /dev/null; then
        print_error "Docker is not running. Please start Docker and try again."
        exit 1
    fi

    # Start services
    docker-compose -f docker-compose.yml -f docker-compose.dev.yml up -d postgres redis

    print_status "Waiting for database to be ready..."
    sleep 10

    print_success "Docker services started!"
}

# Setup database
setup_database() {
    print_status "Setting up database..."

    cd apps/api

    # Generate Prisma client
    npx prisma generate

    # Run migrations
    npx prisma migrate dev --name init

    # Seed database
    npx prisma db seed

    cd - > /dev/null
    print_success "Database setup completed!"
}

# Setup MCP configuration
setup_mcp() {
    print_status "Setting up MCP configuration..."

    # Make scripts executable
    chmod +x tools/mcp-config/generate-worktree-config.sh

    # Set MCP config environment variable
    export CLAUDE_MCP_CONFIG="$(pwd)/tools/mcp-config/mcp-server-config.json"

    print_success "MCP configuration ready!"
    print_status "To use MCP tools, set: export CLAUDE_MCP_CONFIG=\"$(pwd)/tools/mcp-config/mcp-server-config.json\""
}

# Validate setup
validate_setup() {
    print_status "Validating setup..."

    # Check if services are running
    if docker-compose ps | grep -q "Up"; then
        print_success "Docker services are running"
    else
        print_warning "Some Docker services may not be running"
    fi

    # Check database connection
    if docker-compose exec -T postgres pg_isready -U quizztok > /dev/null 2>&1; then
        print_success "Database is accessible"
    else
        print_warning "Database connection test failed"
    fi

    # Check Redis connection
    if docker-compose exec -T redis redis-cli -a dev_redis_123 ping | grep -q "PONG"; then
        print_success "Redis is accessible"
    else
        print_warning "Redis connection test failed"
    fi
}

# Main execution
main() {
    check_dependencies
    setup_environment_files
    install_dependencies
    setup_ssl
    start_docker_services
    setup_database
    setup_mcp
    validate_setup

    echo ""
    print_success "🎉 Development environment setup completed!"
    echo ""
    print_status "Next steps:"
    echo "  1. Start the development servers:"
    echo "     pnpm run dev"
    echo ""
    echo "  2. Access the applications:"
    echo "     - Web Frontend: https://localhost:3000"
    echo "     - API Backend: https://localhost:3001"
    echo "     - API Docs: https://localhost:3001/docs"
    echo ""
    echo "  3. Database management:"
    echo "     - Prisma Studio: cd apps/api && npx prisma studio"
    echo "     - Direct access: docker-compose exec postgres psql -U quizztok quizztok_dev"
    echo ""
    echo "  4. MCP Tools:"
    echo "     - Configuration: ./tools/mcp-config/mcp-server-config.json"
    echo "     - Generate worktree config: ./tools/mcp-config/generate-worktree-config.sh <name>"
    echo ""
}

# Run main function
main "$@"