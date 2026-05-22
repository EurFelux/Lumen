#!/bin/bash
for x in $(seq 700 10 1500); do
  cliclick c:$x,16
  sleep 0.3
  cliclick c:$x,150
  sleep 0.3
  if ! pgrep -f "Lumen.app" > /dev/null; then
    echo "FOUND at x=$x"
    exit 0
  fi
  cliclick c:500,500
  sleep 0.2
done
echo "Not found in range"
