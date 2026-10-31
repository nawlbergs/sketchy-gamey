#!/bin/bash
set -e

# https://www.youtube.com/watch?v=_IK18goX4X8

# prevent infinite loops
if [ -z "$1" ]; then
  echo "Usage: $0 <iterations (number)>"
  exit 1
fi

# Create a hidden temp file for result checking
tmp_file=".claude_output.txt"

#    5. We are working in ./src/app-react which is a react re-write of ./public/auth, ./public/portal, ./public/common
for ((i=1; i<=$1; i++)); do
  echo "Iteration $i"
  echo "-------------------------"

  # 'tee' pipes the output to the screen AND the file simultaneousyly
  unbuffer claude --permission-mode acceptEdits -p "@ralph_prd.json @ralph_progress.txt
    - Find the highest-priority feature to work on and work only on that feature. The features are not in order of priority.
    - Update the ralph_prd.json file with the work that was done.
    - Append your progress to the ralph_progress.txt file.
    - ONLY WORK ON A SINGLE FEATURE.
    - If all items in ralph_prd.json are complete, output: <promise>COMPLETE</promise>" | tee "$tmp_file"

  # Check the temp file for the completion string
  if grep -q "<promise>COMPLETE</promise>" "$tmp_file"; then
    echo "-------------------------"
    echo "PRD complete, exiting."
    rm "$tmp_file"
    exit 0
  fi

  echo -e "\n-------------------------\n"
done

# Cleanup if loop finishes naturally
[ -f "$tmp_file" ] && rm "$tmp_file"
