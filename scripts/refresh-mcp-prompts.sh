#!/bin/bash

# MCP Prompt Refresh Script
# Ensures MCP servers pick up the latest changes to prompt files

echo "🔄 Refreshing MCP Prompts..."
echo "================================================"

# Get current timestamp
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
echo "Refresh Time: $TIMESTAMP"

# Check if prompt files exist and show their modification times
echo ""
echo "📄 Checking Prompt Files:"
echo "------------------------------------------------"

# Data workflow prompts
INTERPRET_INTENT_FILE="src/llm-prompts/data-workflow/interpret_intent.md"
CONTEXT_GAP_FILE="src/llm-prompts/data-workflow/context_gap.md"
GENERATE_CODE_FILE="src/llm-prompts/data-workflow/generate_code.md"
GEN_DOCS_FILE="src/llm-prompts/data-workflow/gen_docs.md"
VALIDATE_RISK_FILE="src/llm-prompts/data-workflow/validate_risk.md"
ROLLBACK_PLAN_FILE="src/llm-prompts/data-workflow/rollback_plan.md"
RUN_DBT_FILE="src/llm-prompts/data-workflow/run_dbt.md"
TEST_RESULTS_FILE="src/llm-prompts/data-workflow/test_results.md"
FIXUP_SUGGESTIONS_FILE="src/llm-prompts/data-workflow/fixup_suggestions.md"
CREATE_PR_FILE="src/llm-prompts/data-workflow/create_pr.md"
MERGE_GUARD_FILE="src/llm-prompts/data-workflow/merge_guard.md"
TAX_CLIENT_SEGMENTATION_FILE="src/llm-prompts/tax_client_segmentation.md"

# Array of all prompt files for easier processing
PROMPT_FILES=(
  "$INTERPRET_INTENT_FILE"
  "$CONTEXT_GAP_FILE"
  "$GENERATE_CODE_FILE"
  "$GEN_DOCS_FILE"
  "$VALIDATE_RISK_FILE"
  "$ROLLBACK_PLAN_FILE"
  "$RUN_DBT_FILE"
  "$TEST_RESULTS_FILE"
  "$FIXUP_SUGGESTIONS_FILE"
  "$CREATE_PR_FILE"
  "$MERGE_GUARD_FILE"
  "$TAX_CLIENT_SEGMENTATION_FILE"
)

# Check each file
for FILE in "${PROMPT_FILES[@]}"; do
  FILENAME=$(basename "$FILE")
  DISPLAY_NAME="${FILENAME%.*}"
  DISPLAY_NAME=$(echo "$DISPLAY_NAME" | sed 's/_/ /g' | sed 's/\b\(.\)/\u\1/g')
  
  if [ -f "$FILE" ]; then
    if command -v stat >/dev/null 2>&1; then
      if stat --version 2>&1 | grep -q 'GNU coreutils'; then
        # GNU stat (Linux)
        MOD_TIME=$(stat -c "%y" "$FILE")
      else
        # BSD stat (macOS)
        MOD_TIME=$(stat -f "%Sm" -t "%Y-%m-%d %H:%M:%S" "$FILE")
      fi
    else
      MOD_TIME="Unknown"
    fi
    echo "✅ $DISPLAY_NAME: $MOD_TIME"
    echo "   Size: $(wc -c < "$FILE") bytes"
  else
    echo "❌ $DISPLAY_NAME: NOT FOUND"
  fi
done

echo ""
echo "🔧 MCP Refresh Strategies:"
echo "------------------------------------------------"

# Strategy 1: Touch files to update modification time
echo "1. Updating file modification times..."
for FILE in "${PROMPT_FILES[@]}"; do
  if [ -f "$FILE" ]; then
    touch "$FILE"
  fi
done

# Strategy 2: Generate file checksums for verification
echo "2. Generating file checksums..."

# Function to get MD5 hash based on available command
get_md5() {
  local file="$1"
  if [ ! -f "$file" ]; then
    echo "N/A"
    return
  fi
  
  if command -v md5 >/dev/null 2>&1; then
    md5 -q "$file" 2>/dev/null || echo "N/A"
  elif command -v md5sum >/dev/null 2>&1; then
    md5sum "$file" 2>/dev/null | cut -d' ' -f1 || echo "N/A"
  else
    echo "N/A"
  fi
}

# Get hashes for all files
INTERPRET_INTENT_HASH=$(get_md5 "$INTERPRET_INTENT_FILE")
CONTEXT_GAP_HASH=$(get_md5 "$CONTEXT_GAP_FILE")
GENERATE_CODE_HASH=$(get_md5 "$GENERATE_CODE_FILE")
GEN_DOCS_HASH=$(get_md5 "$GEN_DOCS_FILE")
VALIDATE_RISK_HASH=$(get_md5 "$VALIDATE_RISK_FILE")
ROLLBACK_PLAN_HASH=$(get_md5 "$ROLLBACK_PLAN_FILE")
RUN_DBT_HASH=$(get_md5 "$RUN_DBT_FILE")
TEST_RESULTS_HASH=$(get_md5 "$TEST_RESULTS_FILE")
FIXUP_SUGGESTIONS_HASH=$(get_md5 "$FIXUP_SUGGESTIONS_FILE")
CREATE_PR_HASH=$(get_md5 "$CREATE_PR_FILE")
MERGE_GUARD_HASH=$(get_md5 "$MERGE_GUARD_FILE")
TAX_CLIENT_SEGMENTATION_HASH=$(get_md5 "$TAX_CLIENT_SEGMENTATION_FILE")

echo "   - Data Workflow Prompts MD5s:"
echo "     - Interpret Intent: $INTERPRET_INTENT_HASH"
echo "     - Context Gap: $CONTEXT_GAP_HASH"
echo "     - Generate Code: $GENERATE_CODE_HASH"
echo "     - Generate Docs: $GEN_DOCS_HASH"
echo "     - Validate Risk: $VALIDATE_RISK_HASH"
echo "     - Rollback Plan: $ROLLBACK_PLAN_HASH"
echo "     - Run DBT: $RUN_DBT_HASH"
echo "     - Test Results: $TEST_RESULTS_HASH"
echo "     - Fixup Suggestions: $FIXUP_SUGGESTIONS_HASH"
echo "     - Create PR: $CREATE_PR_HASH"
echo "     - Merge Guard: $MERGE_GUARD_HASH"
echo "     - Tax Client Segmentation: $TAX_CLIENT_SEGMENTATION_HASH"

# Strategy 3: Create/update manifest file with dynamic version extraction
echo "3. Creating MCP manifest file..."

# Function to extract version from a file
get_version() {
  local file="$1"
  if [ ! -f "$file" ]; then
    echo "unknown"
    return
  fi
  
  # Try different version formats
  local version
  # Try **Version**: format (markdown)
  version=$(grep -E "^\*\*Version\*\*:" "$file" 2>/dev/null | sed 's/.*: *\([0-9.]*\).*/\1/' 2>/dev/null)
  if [ -n "$version" ]; then
    echo "$version"
    return
  fi
  
  # Try # Version: format (prompt files)
  version=$(grep -E "^# Version:" "$file" 2>/dev/null | sed 's/.*: *v*\([0-9.]*\).*/\1/' 2>/dev/null)
  if [ -n "$version" ]; then
    echo "$version"
    return
  fi
  
  echo "0.1.0" # Default version if not found
}

# Get versions for all files
INTERPRET_INTENT_VERSION=$(get_version "$INTERPRET_INTENT_FILE")
CONTEXT_GAP_VERSION=$(get_version "$CONTEXT_GAP_FILE")
GENERATE_CODE_VERSION=$(get_version "$GENERATE_CODE_FILE")
GEN_DOCS_VERSION=$(get_version "$GEN_DOCS_FILE")
VALIDATE_RISK_VERSION=$(get_version "$VALIDATE_RISK_FILE")
ROLLBACK_PLAN_VERSION=$(get_version "$ROLLBACK_PLAN_FILE")
RUN_DBT_VERSION=$(get_version "$RUN_DBT_FILE")
TEST_RESULTS_VERSION=$(get_version "$TEST_RESULTS_FILE")
FIXUP_SUGGESTIONS_VERSION=$(get_version "$FIXUP_SUGGESTIONS_FILE")
CREATE_PR_VERSION=$(get_version "$CREATE_PR_FILE")
MERGE_GUARD_VERSION=$(get_version "$MERGE_GUARD_FILE")
TAX_CLIENT_SEGMENTATION_VERSION=$(get_version "$TAX_CLIENT_SEGMENTATION_FILE")

# Function to get file size
get_file_size() {
  local file="$1"
  if [ -f "$file" ]; then
    wc -c < "$file" 2>/dev/null || echo 0
  else
    echo 0
  fi
}

MANIFEST_FILE="mcp-prompts-manifest.json"
cat > "$MANIFEST_FILE" << EOF
{
  "version": "2.3.0",
  "last_updated": "$TIMESTAMP",
  "prompts": {
    "interpret_intent": {
      "file": "$INTERPRET_INTENT_FILE",
      "version": "$INTERPRET_INTENT_VERSION",
      "hash": "$INTERPRET_INTENT_HASH",
      "size": $(get_file_size "$INTERPRET_INTENT_FILE")
    },
    "context_gap": {
      "file": "$CONTEXT_GAP_FILE",
      "version": "$CONTEXT_GAP_VERSION",
      "hash": "$CONTEXT_GAP_HASH",
      "size": $(get_file_size "$CONTEXT_GAP_FILE")
    },
    "generate_code": {
      "file": "$GENERATE_CODE_FILE",
      "version": "$GENERATE_CODE_VERSION",
      "hash": "$GENERATE_CODE_HASH",
      "size": $(get_file_size "$GENERATE_CODE_FILE")
    },
    "gen_docs": {
      "file": "$GEN_DOCS_FILE",
      "version": "$GEN_DOCS_VERSION",
      "hash": "$GEN_DOCS_HASH",
      "size": $(get_file_size "$GEN_DOCS_FILE")
    },
    "validate_risk": {
      "file": "$VALIDATE_RISK_FILE",
      "version": "$VALIDATE_RISK_VERSION",
      "hash": "$VALIDATE_RISK_HASH",
      "size": $(get_file_size "$VALIDATE_RISK_FILE")
    },
    "rollback_plan": {
      "file": "$ROLLBACK_PLAN_FILE",
      "version": "$ROLLBACK_PLAN_VERSION",
      "hash": "$ROLLBACK_PLAN_HASH",
      "size": $(get_file_size "$ROLLBACK_PLAN_FILE")
    },
    "run_dbt": {
      "file": "$RUN_DBT_FILE",
      "version": "$RUN_DBT_VERSION",
      "hash": "$RUN_DBT_HASH",
      "size": $(get_file_size "$RUN_DBT_FILE")
    },
    "test_results": {
      "file": "$TEST_RESULTS_FILE",
      "version": "$TEST_RESULTS_VERSION",
      "hash": "$TEST_RESULTS_HASH",
      "size": $(get_file_size "$TEST_RESULTS_FILE")
    },
    "fixup_suggestions": {
      "file": "$FIXUP_SUGGESTIONS_FILE",
      "version": "$FIXUP_SUGGESTIONS_VERSION",
      "hash": "$FIXUP_SUGGESTIONS_HASH",
      "size": $(get_file_size "$FIXUP_SUGGESTIONS_FILE")
    },
    "create_pr": {
      "file": "$CREATE_PR_FILE",
      "version": "$CREATE_PR_VERSION",
      "hash": "$CREATE_PR_HASH",
      "size": $(get_file_size "$CREATE_PR_FILE")
    },
    "merge_guard": {
      "file": "$MERGE_GUARD_FILE",
      "version": "$MERGE_GUARD_VERSION",
      "hash": "$MERGE_GUARD_HASH",
      "size": $(get_file_size "$MERGE_GUARD_FILE")
    },
    "tax_client_segmentation": {
      "file": "$TAX_CLIENT_SEGMENTATION_FILE",
      "version": "$TAX_CLIENT_SEGMENTATION_VERSION",
      "hash": "$TAX_CLIENT_SEGMENTATION_HASH",
      "size": $(get_file_size "$TAX_CLIENT_SEGMENTATION_FILE")
    }
  }
}
EOF

echo "   ✅ Created manifest: $MANIFEST_FILE"

echo ""
echo "📋 MCP Integration Instructions:"
echo "------------------------------------------------"
echo "1. Restart your MCP server after running this script"
echo "2. Reference prompts using absolute paths or manifest file"
echo "3. Verify version numbers in MCP responses match above"
echo "4. Use file modification times to confirm latest version"
echo ""
echo "🔗 Reference Methods:"
echo "   - Manifest: $(pwd)/$MANIFEST_FILE"
echo ""
echo "✅ MCP Refresh Complete!"
