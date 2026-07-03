#!/bin/sh
set -eu

if [ "$(id -u)" != "0" ]; then
  echo "run with sudo" >&2
  exit 1
fi

RB=${1:-/SnowUSB3AppleXHCIRollback}
if [ ! -x "$RB/rollback.sh" ]; then
  echo "rollback script not found: $RB/rollback.sh" >&2
  exit 1
fi

"$RB/rollback.sh"
