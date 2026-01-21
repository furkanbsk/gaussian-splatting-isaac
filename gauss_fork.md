# Gaussian Splatting Fork for Isaac Sim

This folder contains the scripts and tools set up to train high-quality 3D Gaussian Splatting models and prepare them for Isaac Sim.

## Initial Setup

1. **Clone the repository** and navigate to the gaussian-splatting directory:
   ```bash
   cd gaussian-splatting
   ```

2. **Copy the configuration template**:
   ```bash
   cp .gsconfig.template .gsconfig
   ```

3. **Create conda environment**:
   ```bash
   conda env create -f environment.yml
   ```

4. **Activate the environment**:
   ```bash
   conda activate gs_env
   ```

5. **(Optional) Customize configuration**: Edit `.gsconfig` to override default settings like Python interpreter path, dataset directories, or Docker settings.

## Prerequisites

1.  **Conda Environment**: `gs_env` (Python 3.8, CUDA 12.1 toolkit installed).
2.  **System Dependencies**: CUDA 12.8 Driver, `colmap`, `ffmpeg`.
3.  **Repositories**:
    *   `gaussian-splatting` (Main repo)
    *   `Depth-Anything-V2` (For depth regularization)

## Configuration

All scripts support customization through the `.gsconfig` file. This allows you to override default behavior without modifying the scripts themselves.

**Common Configuration Options**:
```bash
# Python interpreter override (optional)
GS_PYTHON="/path/to/your/python"

# Conda environment name (default: gs_env)
GS_CONDA_ENV="gs_env"

# Default dataset and output directories
GS_DEFAULT_DATASET="my_room_hq_dataset"
GS_DEFAULT_OUTPUT="my_room_model"

# Default training parameters
GS_DEFAULT_RESOLUTION="2"
GS_DEFAULT_ITERATIONS="60000"

# Docker configuration (for Isaac Sim renderer)
DOCKER_CONTAINER_NAME="vanillags-renderer"
DOCKER_MODEL_MOUNT="/workspace/data"
GS_SOCKET_DIR="/tmp/omni-3dgs-extension"
```

**Note**: The `.gsconfig` file is git-ignored, so your local paths won't be committed to the repository.

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
    # Ensure conda environment is activated
    conda activate gs_env

    # Run from the main directory (where Depth-Anything-V2 is located)
    python Depth-Anything-V2/run.py \
        --encoder vitl --pred-only --grayscale \
        --img-path my_room_hq_dataset/input \
        --outdir my_room_hq_dataset/depths
    ```

    **Note**: Make sure you're in the parent directory containing both `Depth-Anything-V2` and your dataset folder.

2.  **Generate Depth Scales**:
    ```bash
    # Still with gs_env activated
    python gaussian-splatting/utils/make_depth_scale.py \
        --base_dir my_room_hq_dataset \
        --depths_dir my_room_hq_dataset/depths
    ```

    **Tip**: If you get "module not found" errors, ensure:
    - The conda environment `gs_env` is activated
    - You're running from the correct directory
    - Required dependencies are installed (`pip install -r requirements.txt`)
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

All scripts are **location-independent** and automatically detect:
- Repository root directory
- Python interpreter (from activated environment or config)
- Required script paths (train.py, convert.py, etc.)
- System dependencies (ffmpeg, docker, etc.)

**Available Scripts**:
*   `process_data.sh`: Video to COLMAP pipeline.
*   `train.sh`: Basic training wrapper with high-quality defaults.
*   `train_advanced.sh`: Advanced training with depth regularization, exposure compensation, and anti-aliasing.
*   `run_sibr.sh`: Launches the SIBR viewer for real-time visualization.
*   `run_renderer.sh`: Starts the Docker-based renderer for Isaac Sim integration.
*   `export_model.sh`: Helper to copy the latest iteration's PLY file.

**How Scripts Work**:
- Scripts can be run from any directory (they auto-detect their location)
- Python interpreter is detected from your activated environment
- Configuration can be customized via `.gsconfig` without modifying scripts
- Helpful error messages guide you if dependencies are missing

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
