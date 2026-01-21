#!/bin/bash
# Portability Checker for Gaussian Splatting Repository
# This script verifies that no hardcoded paths remain in the codebase

# Get script directory and source common functions
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$SCRIPT_DIR/common.sh"

REPO_ROOT=$(get_repo_root)
cd "$REPO_ROOT"

ISSUES_FOUND=0

echo "========================================"
echo "Gaussian Splatting Portability Check"
echo "========================================"
echo ""

# Test 1: Check for hardcoded user paths
echo "Test 1: Checking for hardcoded user paths"
echo "------------------------------------------"

PATTERNS=(
    "/home/nvidia"
    "/home/[a-zA-Z0-9_-]*/Desktop"
    "miniconda3/envs/gs_env/bin/python"
    "/Users/[a-zA-Z0-9_-]*/Desktop"
    "C:\\\\Users\\\\"
)

for pattern in "${PATTERNS[@]}"; do
    echo "Searching for pattern: $pattern"

    # Search in shell scripts (exclude this check script itself)
    results=$(grep -rn --include="*.sh" --exclude-dir=".git" --exclude="check_portability.sh" -E "$pattern" . 2>/dev/null)

    if [ -n "$results" ]; then
        error "Found hardcoded paths matching '$pattern':"
        echo "$results"
        ISSUES_FOUND=$((ISSUES_FOUND + 1))
    else
        success "No matches for '$pattern' in shell scripts."
    fi
done
echo ""

# Test 2: Check documentation for ungeneric paths
echo "Test 2: Checking documentation files"
echo "-------------------------------------"

DOC_PATTERNS=(
    "/home/nvidia/Desktop/Main_Workspace"
    "/home/nvidia/miniconda3"
    "/home/nvidia/isaacsim[^/]"  # Exact path without variable
)

for pattern in "${DOC_PATTERNS[@]}"; do
    echo "Searching docs for pattern: $pattern"

    results=$(grep -rn --include="*.md" --exclude-dir=".git" -E "$pattern" . 2>/dev/null)

    if [ -n "$results" ]; then
        # Filter out acceptable usage in examples or troubleshooting
        filtered=$(echo "$results" | grep -v "Example:" | grep -v "# List all" | grep -v "ls ~/")

        if [ -n "$filtered" ]; then
            warn "Found potentially hardcoded paths in documentation:"
            echo "$filtered"
            info "Review if these should use <PLACEHOLDER> syntax instead."
            ISSUES_FOUND=$((ISSUES_FOUND + 1))
        else
            success "Pattern '$pattern' only appears in examples (OK)."
        fi
    else
        success "No matches for '$pattern' in documentation."
    fi
done
echo ""

# Test 3: Verify common.sh functions work
echo "Test 3: Testing path detection functions"
echo "-----------------------------------------"

test_function() {
    local func_name=$1
    local description=$2

    if type "$func_name" &>/dev/null; then
        result=$($func_name 2>&1)
        if [ $? -eq 0 ] && [ -n "$result" ]; then
            success "$description: $result"
        else
            warn "$description failed or returned empty."
            ISSUES_FOUND=$((ISSUES_FOUND + 1))
        fi
    else
        error "$func_name is not defined in common.sh!"
        ISSUES_FOUND=$((ISSUES_FOUND + 1))
    fi
}

test_function "get_repo_root" "Repository root detection"
test_function "get_python_interpreter" "Python interpreter detection"
echo ""

# Test 4: Verify configuration template exists
echo "Test 4: Checking configuration files"
echo "-------------------------------------"

if [ -f ".gsconfig.template" ]; then
    success ".gsconfig.template exists."

    # Check if it has required variables
    required_vars=("GS_PYTHON" "GS_CONDA_ENV" "DOCKER_CONTAINER_NAME")
    for var in "${required_vars[@]}"; do
        if grep -q "$var" .gsconfig.template; then
            success "  Template contains: $var"
        else
            warn "  Template missing: $var"
            ISSUES_FOUND=$((ISSUES_FOUND + 1))
        fi
    done
else
    error ".gsconfig.template not found!"
    ISSUES_FOUND=$((ISSUES_FOUND + 1))
fi
echo ""

# Test 5: Check .gitignore
echo "Test 5: Checking .gitignore"
echo "---------------------------"

if [ -f ".gitignore" ]; then
    if grep -q "\.gsconfig" .gitignore; then
        success ".gsconfig is in .gitignore"
    else
        warn ".gsconfig is NOT in .gitignore - user configs may be committed!"
        ISSUES_FOUND=$((ISSUES_FOUND + 1))
    fi
else
    warn ".gitignore not found."
fi
echo ""

# Test 6: Verify scripts source common.sh
echo "Test 6: Checking scripts use common.sh"
echo "---------------------------------------"

main_scripts=("train.sh" "train_advanced.sh" "process_data.sh" "run_sibr.sh" "run_renderer.sh" "export_model.sh")

for script in "${main_scripts[@]}"; do
    if [ -f "$script" ]; then
        if grep -q 'source.*scripts/common\.sh' "$script"; then
            success "$script sources common.sh"
        else
            warn "$script does NOT source common.sh"
            ISSUES_FOUND=$((ISSUES_FOUND + 1))
        fi
    else
        info "$script not found (may be optional)."
    fi
done
echo ""

# Test 7: Check for absolute Python paths in scripts
echo "Test 7: Checking for absolute Python paths"
echo "-------------------------------------------"

python_paths=$(grep -rn --include="*.sh" --exclude-dir=".git" -E "^[[:space:]]*/.*python[0-9.]*[[:space:]]" . 2>/dev/null)

if [ -n "$python_paths" ]; then
    error "Found potential absolute Python paths:"
    echo "$python_paths"
    info "Scripts should use: \$(get_python_interpreter) or just 'python'"
    ISSUES_FOUND=$((ISSUES_FOUND + 1))
else
    success "No absolute Python paths found in scripts."
fi
echo ""

# Test 8: Verify scripts can detect their location
echo "Test 8: Testing script location detection"
echo "------------------------------------------"

for script in "${main_scripts[@]}"; do
    if [ -f "$script" ]; then
        if grep -q 'SCRIPT_DIR=.*dirname.*BASH_SOURCE' "$script"; then
            success "$script has location detection"
        else
            warn "$script may not detect its location properly"
            ISSUES_FOUND=$((ISSUES_FOUND + 1))
        fi
    fi
done
echo ""

# Summary
echo "========================================"
echo "Portability Check Summary"
echo "========================================"
echo ""

if [ $ISSUES_FOUND -eq 0 ]; then
    success "All portability checks passed!"
    echo ""
    info "Your repository is portable and ready for distribution."
    info "Users can clone it to any location and scripts will work."
    echo ""
    exit 0
else
    error "Found $ISSUES_FOUND potential portability issues."
    echo ""
    warn "Please review the issues above and fix them before distribution."
    echo ""
    info "Common fixes:"
    echo "  - Replace absolute paths with \$(get_repo_root)/relative/path"
    echo "  - Use \$(get_python_interpreter) instead of hardcoded Python paths"
    echo "  - Update documentation to use <PLACEHOLDER> syntax"
    echo "  - Ensure all scripts source scripts/common.sh"
    echo ""
    exit 1
fi
