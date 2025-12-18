#!/bin/bash
# Download AgentGym-RL-Data-ID dataset from Hugging Face to workspace/dataset directory
# 
# This script provides two methods:
# Method 1: Using git lfs (recommended for large files)
# Method 2: Using Python datasets library

set -e

DATASET_DIR="/workspace/dataset"
REPO_ID="AgentGym/AgentGym-RL-Data-ID"

# Method selection
METHOD=${1:-"git"}  # Default to git method

if [ "$METHOD" == "git" ]; then
    echo "Using Git LFS method to download dataset..."
    
    # Check if git lfs is installed
    if ! command -v git &> /dev/null; then
        echo "Error: git is not installed. Please install git first."
        exit 1
    fi
    
    # Install git lfs if not already installed
    if ! command -v git-lfs &> /dev/null; then
        echo "Installing git-lfs..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get update && sudo apt-get install -y git-lfs
        elif command -v yum &> /dev/null; then
            sudo yum install -y git-lfs
        else
            echo "Please install git-lfs manually: https://git-lfs.github.com/"
            exit 1
        fi
    fi
    
    # Initialize git lfs
    git lfs install
    
    # Clone the dataset
    if [ -d "$DATASET_DIR" ] && [ "$(ls -A $DATASET_DIR)" ]; then
        echo "Warning: $DATASET_DIR already exists and is not empty."
        echo "Please remove it first or use a different directory."
        exit 1
    fi
    
    echo "Cloning dataset repository..."
    git clone https://huggingface.co/datasets/${REPO_ID} "$DATASET_DIR"
    
    echo "✓ Dataset successfully downloaded to: $DATASET_DIR"
    
elif [ "$METHOD" == "python" ]; then
    echo "Using Python datasets library method..."
    
    # Check if Python is available
    if ! command -v python3 &> /dev/null; then
        echo "Error: python3 is not installed."
        exit 1
    fi
    
    # Run the Python download script
    python3 download_dataset.py --save_path "$DATASET_DIR" --repo_id "$REPO_ID"
    
else
    echo "Usage: $0 [git|python]"
    echo "  git    - Use git lfs to clone the repository (default, recommended)"
    echo "  python - Use Python datasets library to download"
    exit 1
fi

