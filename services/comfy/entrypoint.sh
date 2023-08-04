#!/bin/bash

set -Eeuo pipefail

mkdir -vp /data/config/comfy/custom_nodes

declare -A MOUNTS

MOUNTS["/root/.cache"]="/data/.cache"
MOUNTS["${ROOT}/input"]="/data/config/comfy/input"
MOUNTS["${ROOT}/output"]="/output/comfy"


# MOUNTS["${ROOT}/custom_nodes"]="/data/config/comfy/custom_nodes"
# MOUNTS["${ROOT}/models"]="/data/models"

# RUN --mount=type=cache,target=/var/cache/apt \
#   apt-get update && \
#   # we need those
#   apt-get install -y fonts-dejavu-core rsync git jq moreutils aria2 \
#   # extensions needs those
#   gcc g++ ffmpeg libglfw3-dev libgles2-mesa-dev pkg-config libcairo2 libcairo2-dev build-essential
  
# RUN --mount=type=cache,target=/root/.cache/pip \
#   pip install ifnude favcore mediapipe numba omegaconf insightface ftfy

for to_path in "${!MOUNTS[@]}"; do
  set -Eeuo pipefail
  from_path="${MOUNTS[${to_path}]}"
  rm -rf "${to_path}"
  if [ ! -f "$from_path" ]; then
    mkdir -vp "$from_path"
  fi
  mkdir -vp "$(dirname "${to_path}")"
  ln -sT "${from_path}" "${to_path}"
  echo Mounted $(basename "${from_path}")
done

if [ -f "/data/config/comfy/startup.sh" ]; then
  pushd ${ROOT}
  . /data/config/comfy/startup.sh
  popd
fi

exec "$@"
