#!/bin/bash
# Download Qwen2.5-3B-Instruct model to /workspace/models directory

set -e

hf_model_name="Qwen/Qwen2.5-3B-Instruct"
model_dir="/workspace/models/Qwen2.5-3B-Instruct"

echo "Downloading ${hf_model_name} to ${model_dir}..."

# Create models directory if it doesn't exist
mkdir -p /workspace/models

# Download model using huggingface_hub
python3 << EOF
from huggingface_hub import snapshot_download
import os

model_dir = "${model_dir}"
hf_model_name = "${hf_model_name}"

print(f"Downloading {hf_model_name} to {model_dir}...")
snapshot_download(
    repo_id=hf_model_name,
    local_dir=model_dir,
    local_dir_use_symlinks=False
)
print(f"Model downloaded successfully to {model_dir}")
EOF

echo "Model download completed!"

