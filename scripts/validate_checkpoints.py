#!/usr/bin/env python3
"""
Simple validation script to check user approval checkpoints in prompt files.
Simulates the dialogue validation mentioned in the instructions.
"""

import os
import re
from pathlib import Path

# Define the checkpoint text pattern
CHECKPOINT_PATTERN = r"Here's my analysis\. If this looks right, respond \*\*Proceed\*\*; otherwise clarify\."

# Files that should contain the checkpoint
CHECKPOINT_FILES = [
    "src/llm-prompts/data-workflow/context_gap.md",
    "src/llm-prompts/data-workflow/generate_code.md"
]

def validate_checkpoints():
    """Validate that checkpoint text appears exactly once in each specified file."""
    print("🔍 Validating user approval checkpoints...")
    
    all_valid = True
    
    for file_path in CHECKPOINT_FILES:
        if not os.path.exists(file_path):
            print(f"❌ File not found: {file_path}")
            all_valid = False
            continue
            
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
            
        # Count occurrences of the checkpoint pattern
        matches = re.findall(CHECKPOINT_PATTERN, content)
        count = len(matches)
        
        if count == 1:
            print(f"✅ {file_path}: Checkpoint found exactly once")
        elif count == 0:
            print(f"❌ {file_path}: Checkpoint NOT found")
            all_valid = False
        else:
            print(f"⚠️  {file_path}: Checkpoint found {count} times (should be exactly 1)")
            all_valid = False
    
    if all_valid:
        print("\n🎉 All checkpoints validated successfully!")
        print("💬 Simulated dialogue flow:")
        print("   1. Prompt provides analysis")
        print("   2. Prompt ends with: 'Here's my analysis. If this looks right, respond **Proceed**; otherwise clarify.'")
        print("   3. User responds with 'Proceed' to continue or provides clarification")
        return True
    else:
        print("\n❌ Checkpoint validation failed!")
        return False

if __name__ == "__main__":
    success = validate_checkpoints()
    exit(0 if success else 1) 