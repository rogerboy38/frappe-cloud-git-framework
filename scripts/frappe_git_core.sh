#!/bin/bash
# frappe_git_core.sh - Core Git management for Frappe Cloud
# Version: 1.0.0

set -euo pipefail

# Configuration
CONFIG_DIR="$HOME/.frappe_git"
LOG_FILE="$CONFIG_DIR/operations.log"
PATTERN_DB="$CONFIG_DIR/patterns.json"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() { echo -e "${BLUE}➤${NC} $1"; echo "$(date): $1" >> "$LOG_FILE"; }
success() { echo -e "${GREEN}✓${NC} $1"; echo "$(date): SUCCESS: $1" >> "$LOG_FILE"; }
error() { echo -e "${RED}✗${NC} $1"; echo "$(date): ERROR: $1" >> "$LOG_FILE"; }
warn() { echo -e "${YELLOW}⚠${NC} $1"; echo "$(date): WARNING: $1" >> "$LOG_FILE"; }

# Initialize
init_framework() {
    mkdir -p "$CONFIG_DIR"
    
    # Create pattern database if it doesn't exist
    if [[ ! -f "$PATTERN_DB" ]]; then
        cat > "$PATTERN_DB" << 'JSON'
{
    "ssh_patterns": {
        "success": ["successfully authenticated", "Hi ", "authenticated successfully"],
        "failure": ["Permission denied", "Could not open", "No such file"]
    },
    "git_patterns": {
        "detached_head": ["HEAD detached at", "(no branch)", "not currently on a branch"],
        "remote_issue": ["does not appear to be a git repository", "origin does not appear"]
    },
    "bench_patterns": {
        "fresh_bench": ["fresh container", "new bench", "recent login"],
        "common_issues": ["detached HEAD", "SSH key missing", "remote not set"]
    }
}
JSON
    fi
}

# Pattern recognition (AI-ready)
analyze_pattern() {
    local input="$1"
    local pattern_type="$2"
    
    # Load patterns
    local patterns
    patterns=$(jq -r ".${pattern_type}[]" "$PATTERN_DB" 2>/dev/null)
    
    for pattern in $patterns; do
        if [[ "$input" == *"$pattern"* ]]; then
            echo "$pattern"
            return 0
        fi
    done
    
    echo "unknown"
    return 1
}

# Detect environment
detect_environment() {
    log "Analyzing environment..."
    
    # Check if fresh bench
    if [[ ! -f ~/.ssh/id_ed25519 ]]; then
        warn "Fresh bench detected (no SSH key)"
        echo "fresh_bench"
        return 0
    fi
    
    # Check Git state
    if git rev-parse --git-dir > /dev/null 2>&1; then
        local branch
        branch=$(git branch --show-current 2>/dev/null || echo "")
        
        if [[ -z "$branch" ]]; then
            warn "Detached HEAD state detected"
            echo "detached_head"
            return 0
        fi
    else
        warn "Not a Git repository"
        echo "not_git_repo"
        return 0
    fi
    
    success "Environment appears normal"
    echo "normal"
}

# Fix detached HEAD (your current issue)
fix_detached_head() {
    log "Fixing detached HEAD state..."
    
    # Try different strategies
    if git fetch origin 2>/dev/null; then
        if git show-ref --verify --quiet refs/remotes/origin/main; then
            git checkout -b main origin/main --force && \
            success "Checked out main from origin/main" && return 0
        elif git show-ref --verify --quiet refs/remotes/origin/master; then
            git checkout -b master origin/master --force && \
            success "Checked out master from origin/master" && return 0
        fi
    fi
    
    # Create new branch
    git checkout -b main 2>/dev/null && \
    success "Created new main branch" && return 0
    
    error "Failed to fix detached HEAD"
    return 1
}

# Main workflow
main() {
    init_framework
    
    local env_state
    env_state=$(detect_environment)
    
    case "$env_state" in
        "fresh_bench")
            warn "Fresh bench detected. Run quick_restore.sh first."
            ;;
        "detached_head")
            fix_detached_head
            ;;
        "not_git_repo")
            warn "Not in a Git repository."
            ;;
        "normal")
            success "Git environment is healthy."
            ;;
    esac
    
    # Log for AI training
    echo "{\"timestamp\":\"$(date -Iseconds)\",\"state\":\"$env_state\",\"action\":\"detected\"}" >> "$CONFIG_DIR/ai_training.json"
}

# Run if called directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
