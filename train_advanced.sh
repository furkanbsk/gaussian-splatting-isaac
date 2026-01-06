#!/bin/bash
# Usage: ./train_advanced.sh [dataset_path] [output_name]

DATASET_PATH=$1
OUTPUT_NAME=$2

if [ -z "$DATASET_PATH" ]; then
    DATASET_PATH="my_room_hq_dataset"
fi

if [ -z "$OUTPUT_NAME" ]; then
    OUTPUT_NAME="my_room_advanced"
fi

# Ensure depth path exists
DEPTH_PATH="${DATASET_PATH}/depths"
if [ ! -d "$DEPTH_PATH" ]; then
    echo "Error: Depth directory '$DEPTH_PATH' not found. Please generate depth maps first."
    exit 1
fi

echo "Starting Advanced Training..."
echo "Dataset: $DATASET_PATH"
echo "Output: $OUTPUT_NAME"
echo "Features: Depth Regularization, Exposure Compensation, Anti-aliasing"
echo "Iterations: 30000"

/home/nvidia/miniconda3/envs/gs_env/bin/python gaussian-splatting/train.py \
    -s "$DATASET_PATH" \
    -m "$OUTPUT_NAME" \
    --resolution 4 \
    --iterations 30000 \
    --densify_until_iter 15000 \
    --save_iterations 7000 30000 \
    --data_device cpu \
    --antialiasing \
    --train_test_exp \
    -d "depths"
