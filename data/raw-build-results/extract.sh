#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

echo "Removing existing build-results/"
rm -rf "${DIR}/../build-results"
mkdir -p "${DIR}/../build-results"
touch "${DIR}/../build-results/.gitkeep"
echo "  + Done!"

echo "Extracting build results..."
cat ${DIR}/chunks/build-results-raw.tar.gz.part* \
  | tar -xz -C "${DIR}/../build-results/" --strip-components=2
echo "  + Finished extracting!"

echo "Final directory size is: $(du -hs "${DIR}/../build-results")"
