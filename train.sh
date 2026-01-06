#!/bin/bash
# Usage: ./train.sh <dataset_path> <output_name>

DATASET=$1
OUTPUT_NAME=$2

if [ -z "$DATASET" ]; then
    echo "Usage: ./train.sh <dataset_path> [output_name]"
    exit 1
fi

if [ -z "$OUTPUT_NAME" ]; then
    OUTPUT_NAME="output"
fi

echo "Training on $DATASET..."
echo "Output will be saved to $OUTPUT_NAME"

# Ensure we use the correct environment
eval "$(conda shell.bash hook)"
conda activate gs_env

# Run training with High Quality settings:
# -r 1: Full resolution (4K)
# --iterations 60000: Double the training time
# --densify_until_iter 30000: Densify for longer
# --save_iterations: Save at key points
python gaussian-splatting/train.py -s "$DATASET" -m "$OUTPUT_NAME" --resolution 2 --iterations 60000 --densify_until_iter 30000 --save_iterations 7000 30000 60000 --test_iterations 60000 --data_device cpu
