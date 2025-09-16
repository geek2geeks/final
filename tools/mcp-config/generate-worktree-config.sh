#!/bin/bash

# Generate MCP configuration for specific worktree
# Usage: ./generate-worktree-config.sh <worktree-name> <environment>

WORKTREE_NAME="$1"
ENVIRONMENT="${2:-dev}"
CONFIG_DIR="./tools/mcp-config"
OUTPUT_FILE="$CONFIG_DIR/mcp-${WORKTREE_NAME}.json"

if [ -z "$WORKTREE_NAME" ]; then
    echo "❌ Usage: $0 <worktree-name> [environment]"
    echo "📝 Example: $0 feature-auth dev"
    exit 1
fi

# Base template
BASE_CONFIG="$CONFIG_DIR/mcp-${ENVIRONMENT}.json"

if [ ! -f "$BASE_CONFIG" ]; then
    echo "❌ Base configuration not found: $BASE_CONFIG"
    exit 1
fi

# Copy base config and customize for worktree
cp "$BASE_CONFIG" "$OUTPUT_FILE"

# Update Redis URL with unique database number
DB_NUM=$(($(echo "$WORKTREE_NAME" | cksum | cut -d' ' -f1) % 15 + 1))

# Use platform-appropriate sed command
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    sed -i '' "s|redis://[^@]*@localhost:6379|redis://:dev_redis_123@localhost:6379/$DB_NUM|g" "$OUTPUT_FILE"
else
    # Linux/Windows with Git Bash
    sed -i "s|redis://[^@]*@localhost:6379|redis://:dev_redis_123@localhost:6379/$DB_NUM|g" "$OUTPUT_FILE"
fi

echo "✅ MCP configuration generated for worktree: $WORKTREE_NAME"
echo "📁 Configuration file: $OUTPUT_FILE"
echo "🗃️  Redis database: $DB_NUM"
echo ""
echo "💡 To use this configuration:"
echo "   export CLAUDE_MCP_CONFIG=\"$(pwd)/$OUTPUT_FILE\""