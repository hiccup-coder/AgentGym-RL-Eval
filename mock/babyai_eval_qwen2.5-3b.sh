set -x
export VLLM_USE_MODELSCOPE=0
export VLLM_WORKER_MULTIPROC_METHOD=spawn
export VLLM_ATTENTION_BACKEND=XFORMERS

task_name="babyai"

# Navigate to AgentGym-RL root (if not already there)
if [ -d "AgentGym-RL" ]; then
    cd AgentGym-RL
fi

# Set up Python from conda environment
PYTHON_CMD="python3"
CONDA_ENV_PATH="/venv/agentgym-rl"

# Initialize conda if not already initialized
if ! command -v conda &> /dev/null || [ -z "$CONDA_SHLVL" ]; then
    if [ -f "/opt/miniforge3/etc/profile.d/conda.sh" ]; then
        source /opt/miniforge3/etc/profile.d/conda.sh
    elif [ -f "$HOME/miniconda3/etc/profile.d/conda.sh" ]; then
        source "$HOME/miniconda3/etc/profile.d/conda.sh"
    elif [ -f "$HOME/anaconda3/etc/profile.d/conda.sh" ]; then
        source "$HOME/anaconda3/etc/profile.d/conda.sh"
    fi
fi

# Try to activate conda environment, fallback to direct Python path
if [ "$CONDA_DEFAULT_ENV" != "agentgym-rl" ]; then
    if conda activate agentgym-rl 2>/dev/null; then
        echo "Activated conda environment 'agentgym-rl'"
    elif [ -f "${CONDA_ENV_PATH}/bin/python3" ]; then
        PYTHON_CMD="${CONDA_ENV_PATH}/bin/python3"
        export PATH="${CONDA_ENV_PATH}/bin:$PATH"
        echo "Using Python from ${CONDA_ENV_PATH}"
    else
        echo "Warning: Could not activate conda environment 'agentgym-rl'. Using system Python."
    fi
fi

export VLLM_ATTENTION_BACKEND=XFORMERS

# Workaround for RTX 5090 (sm_120) CUDA compatibility issue
# PyTorch 2.4.0 doesn't have kernels for sm_120
# Note: This is a fundamental limitation - PyTorch 2.4.0 was compiled without sm_120 support
# The patches in vllm_rollout.py will attempt to work around this, but full GPU functionality
# requires PyTorch to be recompiled with sm_120 support or a newer PyTorch version
export CUDA_LAUNCH_BLOCKING=1  # Enable blocking for better error messages
export TORCH_CUDA_ARCH_LIST="8.0;8.6;8.9;9.0"
export CUDA_GRAPH_ENABLED=0
# Try to use CPU fallback for unsupported operations
# Use expandable_segments to avoid fragmentation and reduce max_split_size
export PYTORCH_CUDA_ALLOC_CONF=expandable_segments:True,max_split_size_mb:128

# Baby-ai env server URL
env_server_url="http://0.0.0.0:36001"

sample_num=1
max_rounds=20

# Use local model from /workspace/models directory (static path)
model_path="/workspace/models/Qwen2.5-3B-Instruct"

# Check if model exists, if not, download it
if [ ! -d "${model_path}" ]; then
    echo "Model not found at ${model_path}. Downloading..."
    echo "This may take a while depending on your internet connection..."
    bash "$(dirname "$0")/download_qwen2.5-3b.sh"
else
    echo "Model found at ${model_path}. Using existing model."
fi

HYDRA_FULL_ERROR=1 ${PYTHON_CMD} -m verl.agent_trainer.main_generation  \
    trainer.n_gpus_per_node=1 \
    data.path=/workspace/dataset/eval \
    data.max_prompt_length=512 \
    data.max_response_length=8192 \
    data.n_samples=${sample_num} \
    data.batch_size=8 \
    agentgym.task_name=${task_name} \
    agentgym.env_addr=${env_server_url} \
    agentgym.max_rounds=${max_rounds} \
    agentgym.timeout=500 \
    model.path=${model_path} \
    rollout.gpu_memory_utilization=0.5 \
    rollout.temperature=1 \
    rollout.max_model_len=4096 \
    rollout.max_num_batched_tokens=4096 \
    rollout.max_tokens=512 \
    rollout.tensor_model_parallel_size=1 \
    rollout.rollout_log_dir=executer_logs
status=$?
exit $status

