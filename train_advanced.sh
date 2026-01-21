#!/bin/bash
# Usage: ./train_advanced.sh [dataset_path] [output_name]

# Get script directory and source common functions
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$SCRIPT_DIR/scripts/common.sh"

# Load user configuration
load_config

DATASET_PATH=$1
OUTPUT_NAME=$2

if [ -z "$DATASET_PATH" ]; then
    DATASET_PATH="${GS_DEFAULT_DATASET:-my_room_hq_dataset}"
fi

if [ -z "$OUTPUT_NAME" ]; then
    OUTPUT_NAME="${GS_DEFAULT_OUTPUT:-my_room_advanced}"
fi

# Ensure depth path exists
DEPTH_PATH="${DATASET_PATH}/depths"
if [ ! -d "$DEPTH_PATH" ]; then
    error "Depth directory '$DEPTH_PATH' not found. Please generate depth maps first."
fi

info "Starting Advanced Training..."
info "Dataset: $DATASET_PATH"
info "Output: $OUTPUT_NAME"
info "Features: Depth Regularization, Exposure Compensation, Anti-aliasing"
info "Iterations: 30000"

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

# Run training with advanced features
$PYTHON "$TRAIN_SCRIPT" \
    -s "$DATASET_PATH" \
    -m "$OUTPUT_NAME" \
    --resolution "${GS_DEFAULT_RESOLUTION:-4}" \
    --iterations "${GS_DEFAULT_ITERATIONS:-30000}" \
    --densify_until_iter 15000 \
    --save_iterations 7000 30000 \
    --data_device cpu \
    --antialiasing \
    --train_test_exp \
    -d "depths"
