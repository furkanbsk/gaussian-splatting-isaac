# Gaussian Splatting Fork for Isaac Sim

This folder contains the scripts and tools set up to train high-quality 3D Gaussian Splatting models and prepare them for Isaac Sim.

## Prerequisites

1.  **Conda Environment**: `gs_env` (Python 3.8, CUDA 12.1 toolkit installed).
2.  **System Dependencies**: CUDA 12.8 Driver, `colmap`, `ffmpeg`.
3.  **Repositories**:
    *   `gaussian-splatting` (Main repo)
    *   `Depth-Anything-V2` (For depth regularization)

## Workflow Steps

### 1. Data Processing
Extract frames from your video and run COLMAP to generate the sparse point cloud.

```bash
# Usage: ./process_data.sh <video_path> <output_dataset_name>
./process_data.sh room_full.mp4 my_room_hq_dataset
```
*   **Input**: A video file (e.g., `mp4`, `MOV`).
*   **Output**: A dataset folder containing `input` images and `sparse` COLMAP data.

### 2. Training

#### Option A: Standard Training
Good for quick results or simple scenes.
```bash
# Usage: ./train.sh <dataset_path> [output_model_name]
./train.sh my_room_hq_dataset my_room_model
```

#### Option B: Advanced Training (Recommended)
Includes **Depth Regularization**, **Exposure Compensation**, and **Anti-aliasing**.
Requires `Depth-Anything-V2` to be set up and depth maps generated.

1.  **Generate Depth Maps** (if not done):
    ```bash
    # Run from the main directory
    /home/nvidia/miniconda3/envs/gs_env/bin/python Depth-Anything-V2/run.py \
        --encoder vitl --pred-only --grayscale \
        --img-path my_room_hq_dataset/input \
        --outdir my_room_hq_dataset/depths
    ```
2.  **Generate Depth Scales**:
    ```bash
    /home/nvidia/miniconda3/envs/gs_env/bin/python gaussian-splatting/utils/make_depth_scale.py \
        --base_dir my_room_hq_dataset \
        --depths_dir my_room_hq_dataset/depths
    ```
3.  **Run Training**:
    ```bash
    # Usage: ./train_advanced.sh <dataset_path> [output_model_name]
    ./train_advanced.sh my_room_hq_dataset my_room_advanced
    ```

### 3. Visualization
View your trained model using the compiled SIBR viewer.

```bash
# Usage: ./run_sibr.sh <model_directory>
./run_sibr.sh my_room_advanced
```

### 4. Export
Extract the final PLY file for use in other tools or Isaac Sim.

```bash
# Usage: ./export_model.sh <model_directory> <output_filename>
./export_model.sh my_room_advanced final_room.ply
```

## Scripts Overview
*   `process_data.sh`: Video to COLMAP pipeline.
*   `train.sh`: Basic training wrapper.
*   In `train_advanced.sh`, passed only the folder name `-d "depths"` instead of the full path.
*   `run_sibr.sh`: Launches the SIBR viewer.
*   `export_model.sh`: Helper to copy the latest iteration's PLY file.

## 5. Isaac Sim Visualization (Detailed)

We use the `omni-3dgs-extension` to view the model.
**For full setup instructions, see:** `isaac_sim_visualization.md`

### Quick Start
1.  Ensure you have the extension installed in Isaac Sim.
2.  Start the backend renderer:
    ```bash
    # Ensure you are in the extension directory or have the script
    ./run_renderer.sh
    ```
3.  In Isaac Sim:
    *   Open **3DGS Viewport**.
    *   Create a **Cube**.
    *   Select the Cube.
    *   Click **"S"** in the viewport window.
