#! /bin/bash
# Launch-prefix helper: read site/map from neobot_manager/config/manager_state.yaml
# and exec map_server with:
#   ${NEOBOT_DATABASE}/sites/<site>/<map>/<map>.yaml
#
# Env:
#   NEOBOT_MANAGER_STATE  path to manager_state.yaml (optional)
#   NEOBOT_DATABASE       database root (optional, default: ${HOME}/neobot_database)
#
# Invoked as: run_map_server.bash <map_server_bin> [placeholder.yaml] __name:=...
set -e

DATA_ROOT="${NEOBOT_DATABASE:-${HOME}/neobot_database}"
STATE_FILE="${NEOBOT_MANAGER_STATE:-$(rospack find neobot_manager)/config/manager_state.yaml}"

if [ ! -f "${STATE_FILE}" ]; then
  echo "[run_map_server] manager_state not found: ${STATE_FILE}" >&2
  exit 1
fi

read -r SITE MAP <<< "$(python3 - "${STATE_FILE}" <<'PY'
import sys
import yaml

with open(sys.argv[1], "r") as f:
    data = yaml.safe_load(f) or {}

site = (data.get("site") or "default").strip()
map_name = (data.get("map") or "default").strip()
print(site, map_name)
PY
)"

if [ -z "${SITE}" ] || [ -z "${MAP}" ]; then
  echo "[run_map_server] invalid site/map in ${STATE_FILE}" >&2
  exit 1
fi

MAP_FILE="${DATA_ROOT}/sites/${SITE}/${MAP}/${MAP}.yaml"

if [ ! -f "${MAP_FILE}" ]; then
  GAZEBO_MAP="$(rospack find neobot_gazebo)/maps/${MAP}.yaml"
  if [ -f "${GAZEBO_MAP}" ]; then
    echo "[run_map_server] database map missing, fallback to gazebo: ${GAZEBO_MAP}" >&2
    MAP_FILE="${GAZEBO_MAP}"
  else
    echo "[run_map_server] map file not found: ${MAP_FILE}" >&2
    exit 1
  fi
fi

echo "[run_map_server] manager_state site=${SITE} map=${MAP} -> ${MAP_FILE}"

BIN="$1"
shift
# Drop placeholder map path from launch args, keep ROS remaps/params.
if [ $# -gt 0 ] && [[ "$1" == *.yaml ]]; then
  shift
fi

exec "${BIN}" "${MAP_FILE}" "$@"
