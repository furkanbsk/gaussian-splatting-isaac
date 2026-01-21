#!/bin/bash
# Common functions for Gaussian Splatting scripts
# Auto-detects paths and environments for portability
# Source this file from other scripts to use these functions

# Detect script location and repo root
get_repo_root() {
    # Get the directory containing the script that sourced this file
    local source_dir="$( cd "$( dirname "${BASH_SOURCE[1]}" )" && pwd )"

    # If script is in scripts/ subdirectory, go up one level
    if [[ "$(basename "$source_dir")" == "scripts" ]]; then
        echo "$(dirname "$source_dir")"
    else
        echo "$source_dir"
    fi
}

# Detect Python interpreter
get_python_interpreter() {
    # Priority order:
    # 1. GS_PYTHON environment variable (user override)
    # 2. Currently activated conda/venv environment
    # 3. Detect conda environment by name pattern (gs_env, gaussian_splatting)
    # 4. System python3

    if [[ -n "$GS_PYTHON" ]]; then
        echo "$GS_PYTHON"
        return 0
    fi

    # Check if we're in an activated conda environment
    if [[ -n "$CONDA_DEFAULT_ENV" ]]; then
        echo "python"
        return 0
    fi

    # Check if we're in a venv
    if [[ -n "$VIRTUAL_ENV" ]]; then
        echo "python"
        return 0
    fi

    # Try to find conda environment by common names
    if command -v conda &> /dev/null; then
        local env_name="${GS_CONDA_ENV:-gs_env}"
        if conda env list | grep -q "^$env_name "; then
            echo "conda run -n $env_name python"
            return 0
        fi

        # Try alternative name
        if conda env list | grep -q "^gaussian_splatting "; then
            echo "conda run -n gaussian_splatting python"
            return 0
        fi
    fi

    # Fallback to system python
    if command -v python3 &> /dev/null; then
        echo "python3"
    else
        echo "python"
    fi
}

# Ensure conda is available and activate environment
ensure_conda_env() {
    local env_name="${1:-${GS_CONDA_ENV:-gs_env}}"

    # Check if already in the correct environment
    if [[ "$CONDA_DEFAULT_ENV" == "$env_name" ]]; then
        return 0
    fi

    # Initialize conda for bash
    if command -v conda &> /dev/null; then
        # Check if conda is initialized for this shell
        if ! type conda | grep -q "function"; then
            eval "$(conda shell.bash hook)" 2>/dev/null || true
        fi

        conda activate "$env_name" 2>/dev/null || {
            echo "Warning: Could not activate conda environment '$env_name'" >&2
            echo "Please ensure the environment exists or activate it manually:" >&2
            echo "  conda activate $env_name" >&2
            return 1
        }
    else
        echo "Warning: Conda not found. Proceeding with system Python." >&2
        echo "If you need conda, please install it or activate your environment manually." >&2
        return 1
    fi
}

# Convert relative path to absolute path based on repo root
resolve_path() {
    local path="$1"
    local repo_root="$(get_repo_root)"

    if [[ "$path" = /* ]]; then
        # Already absolute
        echo "$path"
    else
        # Make relative to repo root
        echo "$repo_root/$path"
    fi
}

# Load user configuration if exists
load_config() {
    local repo_root="$(get_repo_root)"
    local config_file="$repo_root/.gsconfig"

    if [[ -f "$config_file" ]]; then
        source "$config_file"
    fi
}

# Check if a command exists
command_exists() {
    command -v "$1" &> /dev/null
}

# Print info message
info() {
    echo "[INFO] $*" >&2
}

# Print warning message
warn() {
    echo "[WARN] $*" >&2
}

# Print error message and exit
error() {
    echo "[ERROR] $*" >&2
    exit 1
}

# Print success message
success() {
    echo "[OK] $*" >&2
}

# Export functions for use in other scripts
export -f get_repo_root
export -f get_python_interpreter
export -f ensure_conda_env
export -f resolve_path
export -f load_config
export -f command_exists
export -f info
export -f warn
export -f error
export -f success
