#! /bin/bash
# Launch-prefix helper: map_server only accepts the map path via argv, not rosparam.
# Read /neobot/map_name (loaded from neobot_init.yaml) and exec map_server with that file.
# Invoked as: run_map_server.bash <map_server_bin> [placeholder.yaml] __name:=... __log:=...
set -e

MAPS_DIR="$(rospack find neobot_gazebo)/maps"
MAP_NAME="$(rosparam get /neobot/map_name | tr -d "'\"")"
MAP_FILE="${MAPS_DIR}/${MAP_NAME}.yaml"

if [ -z "${MAP_NAME}" ] || [ "${MAP_NAME}" = "null" ]; then
  echo "[run_map_server] /neobot/map_name not set (load neobot_init.yaml first)" >&2
  exit 1
fi

if [ ! -f "${MAP_FILE}" ]; then
  echo "[run_map_server] map file not found: ${MAP_FILE}" >&2
  exit 1
fi

echo "[run_map_server] /neobot/map_name=${MAP_NAME} -> ${MAP_FILE}"

BIN="$1"
shift
# Drop the placeholder map path from the launch args, keep ROS remaps/params.
if [ $# -gt 0 ] && [[ "$1" == *.yaml ]]; then
  shift
fi

exec "${BIN}" "${MAP_FILE}" "$@"
