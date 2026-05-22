#!/bin/bash
items=(
  "883,16"
  "920,16"
  "993,16"
  "1071,16"
  "1109,16"
  "1188,16"
  "1236,16"
  "1274,16"
  "1344,16"
)

for item in "${items[@]}"; do
  echo "=== Clicking at $item ==="
  cliclick c:$item
  sleep 0.3
  swift list_windows.swift 2>&1 | grep "49608\|Lumen" || echo "No Lumen windows found"
  cliclick c:500,500
  sleep 0.2
done
