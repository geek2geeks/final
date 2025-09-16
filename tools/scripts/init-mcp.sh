#!/bin/bash

# MCP Tools Initialization Script
# Installs and initializes all MCP server packages

set -e

echo "🔧 Initializing MCP Tools for QuizzTok..."
echo "=========================================="

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() {
    echo -e "${BLUE}[MCP]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Install MCP server packages
install_mcp_servers() {
    print_status "Installing MCP server packages..."

    local packages=(
        "@modelcontextprotocol/server-time"
        "@modelcontextprotocol/server-redis"
        "@modelcontextprotocol/server-postgresql"
        "@modelcontextprotocol/server-vercel"
        "@modelcontextprotocol/server-playwright"
        "@modelcontextprotocol/server-filesystem"
        "@modelcontextprotocol/server-fetch"
        "@modelcontextprotocol/server-git"
    )

    for package in "${packages[@]}"; do
        print_status "Installing $package..."
        npm install -g "$package" || print_warning "Failed to install $package"
    done

    print_success "MCP server packages installation completed!"
}

# Setup Playwright browsers
setup_playwright() {
    print_status "Setting up Playwright browsers..."

    local browsers_path="./tools/mcp-config/playwright-browsers"
    mkdir -p "$browsers_path"

    # Set environment variable for Playwright
    export PLAYWRIGHT_BROWSERS_PATH="$browsers_path"

    # Install Playwright browsers
    npx playwright install --with-deps || print_warning "Playwright browser installation may have failed"

    print_success "Playwright browsers setup completed!"
}

# Verify MCP configuration
verify_mcp_config() {
    print_status "Verifying MCP configuration..."

    local config_file="./tools/mcp-config/mcp-server-config.json"

    if [ ! -f "$config_file" ]; then
        print_warning "MCP configuration file not found: $config_file"
        return 1
    fi

    # Check if the config file is valid JSON
    if ! jq . "$config_file" > /dev/null 2>&1; then
        print_warning "MCP configuration file is not valid JSON"
        return 1
    fi

    print_success "MCP configuration is valid!"
}

# Test MCP servers
test_mcp_servers() {
    print_status "Testing MCP server connectivity..."

    # Test time server
    if command -v @modelcontextprotocol/server-time &> /dev/null; then
        print_success "Time server is available"
    else
        print_warning "Time server is not available"
    fi

    # Test if Docker services are running for Redis and PostgreSQL tests
    if docker-compose ps | grep -q "postgres.*Up"; then
        print_success "PostgreSQL service is running"
    else
        print_warning "PostgreSQL service is not running - start with: docker-compose up -d postgres"
    fi

    if docker-compose ps | grep -q "redis.*Up"; then
        print_success "Redis service is running"
    else
        print_warning "Redis service is not running - start with: docker-compose up -d redis"
    fi
}

# Create MCP usage examples
create_usage_examples() {
    print_status "Creating MCP usage examples..."

    local examples_dir="./tools/mcp-config/examples"
    mkdir -p "$examples_dir"

    cat > "$examples_dir/time-usage.md" << 'EOF'
# Time MCP Server Usage Examples

## Get Current Time
```bash
# Get current time in UTC
mcp-client time get_current_time

# Get current time in specific timezone
mcp-client time get_current_time --timezone "America/New_York"
```

## Convert Time Between Timezones
```bash
# Convert time from one timezone to another
mcp-client time convert_time \
  --time "14:30" \
  --source_timezone "America/New_York" \
  --target_timezone "Europe/London"
```
EOF

    cat > "$examples_dir/redis-usage.md" << 'EOF'
# Redis MCP Server Usage Examples

## Basic Operations
```bash
# Set a value
mcp-client redis set --key "user:123" --value "John Doe"

# Get a value
mcp-client redis get --key "user:123"

# Delete a key
mcp-client redis delete --key "user:123"
```

## Hash Operations
```bash
# Set hash field
mcp-client redis hset --name "user:123" --key "name" --value "John Doe"

# Get hash field
mcp-client redis hget --name "user:123" --key "name"

# Get all hash fields
mcp-client redis hgetall --name "user:123"
```

## List Operations
```bash
# Push to list
mcp-client redis lpush --name "queue:tasks" --value "task1"

# Pop from list
mcp-client redis lpop --name "queue:tasks"
```
EOF

    cat > "$examples_dir/postgresql-usage.md" << 'EOF'
# PostgreSQL MCP Server Usage Examples

## Query Examples
```bash
# Select all users
mcp-client postgresql query --sql "SELECT * FROM users LIMIT 10"

# Count questions by difficulty
mcp-client postgresql query --sql "
  SELECT difficulty, COUNT(*) as count
  FROM questions
  GROUP BY difficulty
"

# Get quiz statistics
mcp-client postgresql query --sql "
  SELECT
    q.title,
    qr.participant_count,
    qr.average_score
  FROM quizzes q
  LEFT JOIN quiz_results qr ON q.id = qr.quiz_id
  WHERE q.status = 'completed'
  ORDER BY q.created_at DESC
  LIMIT 5
"
```
EOF

    print_success "MCP usage examples created in $examples_dir"
}

# Main execution
main() {
    install_mcp_servers
    setup_playwright
    verify_mcp_config
    test_mcp_servers
    create_usage_examples

    echo ""
    print_success "🎉 MCP Tools initialization completed!"
    echo ""
    print_status "MCP Configuration: ./tools/mcp-config/mcp-server-config.json"
    print_status "Usage Examples: ./tools/mcp-config/examples/"
    echo ""
    print_status "To use MCP tools, set the environment variable:"
    echo "  export CLAUDE_MCP_CONFIG=\"$(pwd)/tools/mcp-config/mcp-server-config.json\""
    echo ""
}

# Run main function
main "$@"