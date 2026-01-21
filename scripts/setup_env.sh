#!/bin/bash
# Setup Environment Helper for Gaussian Splatting
# Run this script once after cloning the repository to set up your environment

# Get script directory and source common functions
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$SCRIPT_DIR/common.sh"

echo "========================================"
echo "Gaussian Splatting Environment Setup"
echo "========================================"
echo ""

# Get repository root
REPO_ROOT=$(get_repo_root)
cd "$REPO_ROOT"

# Step 1: Create .gsconfig from template
echo "Step 1: Configuration File"
echo "--------------------------"
if [ -f ".gsconfig" ]; then
    info ".gsconfig already exists. Skipping."
else
    if [ -f ".gsconfig.template" ]; then
        cp .gsconfig.template .gsconfig
        success ".gsconfig created from template."
        info "You can customize it by editing: $REPO_ROOT/.gsconfig"
    else
        warn ".gsconfig.template not found. You may need to create .gsconfig manually."
    fi
fi
echo ""

# Step 2: Check for Conda
echo "Step 2: Conda Environment"
echo "-------------------------"
if command_exists conda; then
    success "Conda is installed."

    # Check if gs_env exists
    if conda env list | grep -q "^gs_env "; then
        success "Conda environment 'gs_env' exists."
        info "To activate: conda activate gs_env"
    else
        warn "Conda environment 'gs_env' not found."

        # Check if environment.yml exists
        if [ -f "environment.yml" ]; then
            echo ""
            read -p "Create conda environment from environment.yml? (y/n): " -n 1 -r
            echo ""
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                info "Creating conda environment..."
                conda env create -f environment.yml
                if [ $? -eq 0 ]; then
                    success "Environment created successfully!"
                    info "Activate it with: conda activate gs_env"
                else
                    error "Failed to create environment. Check the logs above."
                fi
            else
                info "Skipped environment creation."
                info "Create it later with: conda env create -f environment.yml"
            fi
        else
            warn "environment.yml not found in repository root."
            info "You'll need to set up the Python environment manually."
        fi
    fi
else
    warn "Conda is not installed or not in PATH."
    info "Install Miniconda or Anaconda from: https://docs.conda.io/en/latest/miniconda.html"
fi
echo ""

# Step 3: Check system dependencies
echo "Step 3: System Dependencies"
echo "---------------------------"

check_dependency() {
    local cmd=$1
    local name=$2
    local install_hint=$3

    if command_exists "$cmd"; then
        success "$name is installed."
    else
        warn "$name is NOT installed."
        if [ -n "$install_hint" ]; then
            info "  Install with: $install_hint"
        fi
    fi
}

check_dependency "ffmpeg" "FFmpeg" "sudo apt install ffmpeg"
check_dependency "colmap" "COLMAP" "sudo apt install colmap"
check_dependency "docker" "Docker" "https://docs.docker.com/engine/install/"
echo ""

# Step 4: Check SIBR Viewer
echo "Step 4: SIBR Viewer"
echo "-------------------"
SIBR_VIEWER="$REPO_ROOT/SIBR_viewers/install/bin/SIBR_gaussianViewer_app"

if [ -f "$SIBR_VIEWER" ]; then
    success "SIBR viewer is compiled."
    info "Location: $SIBR_VIEWER"
else
    warn "SIBR viewer not found."
    info "You'll need to compile it to use real-time visualization."
    info "See README.md or SIBR_viewers/README.md for compilation instructions."
fi
echo ""

# Step 5: Check Python packages (if conda env is active)
echo "Step 5: Python Packages"
echo "-----------------------"
if [ -n "$CONDA_DEFAULT_ENV" ] && [ "$CONDA_DEFAULT_ENV" = "gs_env" ]; then
    info "Checking Python packages in active 'gs_env' environment..."

    # Check key packages
    check_python_package() {
        local package=$1
        if python -c "import $package" 2>/dev/null; then
            success "$package is installed."
        else
            warn "$package is NOT installed."
            info "  Install with: pip install $package"
        fi
    }

    check_python_package "torch"
    check_python_package "torchvision"
    check_python_package "numpy"
    check_python_package "opencv-python" "cv2"
else
    info "Conda environment 'gs_env' is not active."
    info "Activate it first to check Python packages: conda activate gs_env"
fi
echo ""

# Step 6: Repository structure
echo "Step 6: Repository Structure"
echo "----------------------------"
info "Checking for required directories and files..."

check_path() {
    local path=$1
    local description=$2

    if [ -e "$path" ]; then
        success "$description exists."
    else
        warn "$description NOT found: $path"
    fi
}

check_path "$REPO_ROOT/train.py" "Training script"
check_path "$REPO_ROOT/convert.py" "COLMAP conversion script"
check_path "$REPO_ROOT/train.sh" "Training wrapper"
check_path "$REPO_ROOT/process_data.sh" "Data processing wrapper"
echo ""

# Summary
echo "========================================"
echo "Setup Summary"
echo "========================================"
echo ""

if [ -f ".gsconfig" ] && conda env list | grep -q "^gs_env " && command_exists ffmpeg && command_exists colmap; then
    success "Your environment is ready!"
    echo ""
    info "Next steps:"
    echo "  1. Activate conda environment: conda activate gs_env"
    echo "  2. Process your video: ./process_data.sh <video> <output_dir>"
    echo "  3. Train a model: ./train.sh <dataset> <model_name>"
    echo "  4. Visualize: ./run_sibr.sh <model_name>"
else
    warn "Some setup steps are incomplete."
    info "Review the warnings above and install missing dependencies."
fi
echo ""
info "For detailed documentation, see:"
echo "  - gauss_fork.md (workflow guide)"
echo "  - isaac_sim_visualization.md (Isaac Sim integration)"
echo "  - troubleshooting.md (common issues)"
echo ""
