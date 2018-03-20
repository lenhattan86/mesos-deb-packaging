#!/bin/bash
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

set -eu

print_available_builders() {
  find builder -name Dockerfile | sed "s/\/Dockerfile$//"
}

if [[ $# -lt 3 ]]; then
  echo "usage: $0 BUILDER REPO MESOS_VERSION BUILD"
  echo 'BUILDER is a builder directory in:'
  print_available_builders
  echo "REPO is mesos repository" 
  echo "MESOS_VERSION is one of the mesos release tags/branch"
  echo "BUILD is an optional release tag (default 1)" 
  exit 1
else
  BUILDER_DIR=$1
  REPO=$2
  MESOS_VERSION=$3
  BUILD=${4-"1"}
  
fi

IMAGE_NAME="mesos-$(basename $BUILDER_DIR)"
echo "Using docker image $IMAGE_NAME"
docker build -t "$IMAGE_NAME" "$BUILDER_DIR"

ARTIFACT_DIR="$(pwd)/dist/$BUILDER_DIR"
mkdir -p $ARTIFACT_DIR
docker run \
  --rm \
  -e MESOS_VERSION=$MESOS_VERSION \
  -e REPO=$REPO \
  -e BUILD=$BUILD \
  -v "$(pwd):/mesos-packaging:ro" \
  -v "$ARTIFACT_DIR:/dist" \
  -t "$IMAGE_NAME" /build.sh

echo "Produced artifacts in $ARTIFACT_DIR:"
ls $ARTIFACT_DIR
