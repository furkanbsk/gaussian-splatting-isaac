#!/bin/bash
# Usage: ./run_sibr.sh [model_path]

# Get script directory and source common functions
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$SCRIPT_DIR/scripts/common.sh"

# Load user configuration
load_config

MODEL_PATH=$1

if [ -z "$MODEL_PATH" ]; then
    MODEL_PATH="${GS_DEFAULT_OUTPUT:-my_room_hq_model}"
fi

if [ ! -d "$MODEL_PATH" ]; then
    error "Model directory '$MODEL_PATH' not found.
Usage: ./run_sibr.sh <model_dir>"
fi

info "Launching SIBR Viewer for $MODEL_PATH..."

# Get repo root and resolve SIBR viewer path
REPO_ROOT=$(get_repo_root)
SIBR_VIEWER="$REPO_ROOT/SIBR_viewers/install/bin/SIBR_gaussianViewer_app"

if [ ! -f "$SIBR_VIEWER" ]; then
    error "SIBR viewer not found at: $SIBR_VIEWER
Please compile SIBR viewer first.
See README.md for compilation instructions."
fi

# Make SIBR viewer executable if not already
chmod +x "$SIBR_VIEWER" 2>/dev/null

# Run SIBR viewer
"$SIBR_VIEWER" -m "$MODEL_PATH"
