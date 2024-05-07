#!/bin/bash

# Copyright 2024 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# https://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# What does this script do?
# This script automates the following tasks to produce a zip file for
# sideloading to a Roku device:
# 1. Create the `sample/source` folder
# 2. Copy the `gam_utils.brs` file from the current working directory into the
#    `sample/source` directory.
# 3. Compress all the files in the `sample/` folder into a `sample.zip` file.
# 4. Delete the subfolder that was created in step 2, including the copy of
#    `gam_utils.brs`.
# 5. Move the `sample.zip` file to the current working directory.

PWD=$(pwd)
FILENAME="gam_utils.brs"
SCRIPT_DIR=$(realpath "$(dirname "$0")")
GAM_UTILS="${SCRIPT_DIR}/${FILENAME}"
SAMPLE_DIR="${SCRIPT_DIR}/sample"
SUBFOLDER="${SAMPLE_DIR}/source"
SAMPLE_GAM_UTILS_TARGET="${SUBFOLDER}/${FILENAME}"

pushd "$SAMPLE_DIR"
mkdir "$SUBFOLDER"
cp -f "$GAM_UTILS" "$SAMPLE_GAM_UTILS_TARGET"
zip -r sample.zip *
rm -r "$SUBFOLDER"
popd
mv "${SAMPLE_DIR}/sample.zip" "$PWD"
