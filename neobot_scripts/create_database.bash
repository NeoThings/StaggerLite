#! /bin/bash
# Check / Create NeoBot local database layout:
#   neobot_database/
#   ├── bags
#   ├── configs
#   ├── logs
#   ├── sites
#   │   └── default
#   │       ├── maps
#   │       └── tasks
#   └── worlds
#
# Usage:
#   ./create_database.bash              # default: ${HOME}/neobot_database
#   ./create_database.bash /path/to/dir # custom root
#   NEOBOT_DATABASE=/path/to/dir ./create_database.bash

set -e

DATA_ROOT="${1:-${NEOBOT_DATABASE:-${HOME}/neobot_database}}"
SUBDIRS=(
  bags
  configs
  logs
  worlds
  sites/default/maps
  sites/default/tasks
)

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

if [ "${missing}" -eq 0 ]; then
  echo "Database check passed."
else
  echo "Created ${missing} missing directory(ies)."
fi

echo "export NEOBOT_DATABASE=${DATA_ROOT}"
