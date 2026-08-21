#! /bin/bash
# Check / Create NeoBot local database layout:
#   neobot_database/
#   ├── bags
#   ├── configs
#   ├── logs
#   ├── sites
#   │   └── default
#   │       └── default
#   │           ├── default.yaml
#   │           ├── default.pgm
#   │           └── poses.json   (optional, created by save_map)
#   └── worlds
#
# Usage:
#   ./create_database.bash              # default: ${HOME}/neobot_database
#   ./create_database.bash /path/to/dir # custom root
#   NEOBOT_DATABASE=/path/to/dir ./create_database.bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GAZEBO_MAPS_DIR="${SCRIPT_DIR}/../neobot_gazebo/maps"

DATA_ROOT="${1:-${NEOBOT_DATABASE:-${HOME}/neobot_database}}"
SUBDIRS=(
  bags
  configs
  logs
  worlds
  sites/default/default
)

DEFAULT_SITE_MAP_DIR="${DATA_ROOT}/sites/default/default"
DEFAULT_MAP_FILES=(default.yaml default.pgm)

echo "NeoBot database root: ${DATA_ROOT}"

if [ ! -d "${DATA_ROOT}" ]; then
  echo "[CREATE] ${DATA_ROOT}"
  mkdir -p "${DATA_ROOT}"
else
  echo "[OK]     ${DATA_ROOT}"
fi

missing=0
for d in "${SUBDIRS[@]}"; do
  path="${DATA_ROOT}/${d}"
  if [ ! -d "${path}" ]; then
    echo "[CREATE] ${path}"
    mkdir -p "${path}"
    missing=$((missing + 1))
  else
    echo "[OK]     ${path}"
  fi
done

if [ ! -d "${GAZEBO_MAPS_DIR}" ]; then
  echo "[WARN]   gazebo maps not found: ${GAZEBO_MAPS_DIR}" >&2
else
  for map_file in "${DEFAULT_MAP_FILES[@]}"; do
    src="${GAZEBO_MAPS_DIR}/${map_file}"
    dst="${DEFAULT_SITE_MAP_DIR}/${map_file}"
    if [ ! -f "${src}" ]; then
      echo "[WARN]   missing source map file: ${src}" >&2
      continue
    fi
    if [ -f "${dst}" ]; then
      echo "[OK]     ${dst} (exists, skip copy)"
    else
      cp "${src}" "${dst}"
      echo "[COPY]   ${src} -> ${dst}"
    fi
  done
fi

if [ "${missing}" -eq 0 ]; then
  echo "Database check passed."
else
  echo "Created ${missing} missing directory(ies)."
fi

echo "export NEOBOT_DATABASE=${DATA_ROOT}"
