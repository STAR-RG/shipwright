#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

rm -rf "${DIR}/../build-results"
mkdir -p "${DIR}/../build-results"
touch "${DIR}/../build-results/.gitkeep"

echo "Extracting build results..."
cat ${DIR}/chunks/build-results-raw.tar.gz.part* \
  | tar -xz -C build-results/ --strip-components=2
echo "  + Finished extracting!"
