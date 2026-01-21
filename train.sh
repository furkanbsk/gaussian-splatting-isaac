#!/bin/bash
# Usage: ./train.sh <dataset_path> <output_name>

# Get script directory and source common functions
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$SCRIPT_DIR/scripts/common.sh"

# Load user configuration
load_config

DATASET=$1
OUTPUT_NAME=$2

if [ -z "$DATASET" ]; then
    echo "Usage: ./train.sh <dataset_path> [output_name]"
    exit 1
fi

if [ -z "$OUTPUT_NAME" ]; then
    OUTPUT_NAME="${GS_DEFAULT_OUTPUT:-output}"
fi

info "Training on $DATASET..."
info "Output will be saved to $OUTPUT_NAME"

# Ensure conda environment (if needed)
ensure_conda_env "${GS_CONDA_ENV:-gs_env}"

# Get Python interpreter
PYTHON=$(get_python_interpreter)
info "Using Python: $PYTHON"

# Get repo root and resolve train.py path
REPO_ROOT=$(get_repo_root)
TRAIN_SCRIPT="$REPO_ROOT/train.py"

if [ ! -f "$TRAIN_SCRIPT" ]; then
    error "Training script not found at: $TRAIN_SCRIPT"
fi

# Run training with High Quality settings:
# -r 2: Half resolution (2K from 4K)
# --iterations 60000: Double the training time
# --densify_until_iter 30000: Densify for longer
# --save_iterations: Save at key points
$PYTHON "$TRAIN_SCRIPT" \
    -s "$DATASET" \
    -m "$OUTPUT_NAME" \
    --resolution "${GS_DEFAULT_RESOLUTION:-2}" \
    --iterations "${GS_DEFAULT_ITERATIONS:-60000}" \
    --densify_until_iter 30000 \
    --save_iterations 7000 30000 60000 \
    --test_iterations 60000 \
    --data_device cpu
