#!/usr/bin/env python3
"""
Download AgentGym-RL-Data-ID dataset from Hugging Face to workspace/dataset directory.
"""

import argparse
import os
from pathlib import Path
from datasets import load_dataset

def main():
    parser = argparse.ArgumentParser(
        description="Download AgentGym-RL-Data-ID dataset from Hugging Face"
    )
    parser.add_argument(
        "--repo_id",
        type=str,
        default="AgentGym/AgentGym-RL-Data-ID",
        help="Hugging Face repository ID (default: AgentGym/AgentGym-RL-Data-ID)"
    )
    parser.add_argument(
        "--save_path",
        type=str,
        default="/workspace/dataset",
        help="Local directory to save the dataset (default: /workspace/dataset)"
    )
    parser.add_argument(
        "--cache_dir",
        type=str,
        default=None,
        help="Cache directory for datasets library (optional)"
    )
    
    args = parser.parse_args()
    
    # Convert to Path objects
    save_path = Path(args.save_path)
    
    # Create save directory if it doesn't exist
    save_path.mkdir(parents=True, exist_ok=True)
    
    print(f"Downloading dataset from: {args.repo_id}")
    print(f"Saving to: {save_path}")
    print("This may take a while depending on your internet connection...")
    
    try:
        # Load the dataset
        dataset = load_dataset(
            args.repo_id,
            cache_dir=args.cache_dir
        )
        
        # Save the dataset to disk
        dataset.save_to_disk(str(save_path))
        
        print(f"\n✓ Dataset successfully downloaded to: {save_path}")
        print(f"\nDataset structure:")
        print(f"  Keys: {list(dataset.keys())}")
        for key in dataset.keys():
            print(f"  {key}: {len(dataset[key])} examples")
            
    except Exception as e:
        print(f"\n✗ Error downloading dataset: {e}")
        print("\nTroubleshooting:")
        print("1. Make sure you have the 'datasets' library installed: pip install datasets")
        print("2. Check your internet connection")
        print("3. Verify the repository ID is correct")
        raise

if __name__ == "__main__":
    main()

