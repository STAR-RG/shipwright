#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

rm -f "${DIR}/results-binnacle.txt"
touch "${DIR}/results-binnacle.txt"

echo "Running binnacle on broken dockerfiles..."
while read f; do
    target="${DIR}/../data/broken-dockerfiles/$(basename $(dirname $f)).Dockerfile"
    docker run --rm -i jjhenkel/binnacle analyze-stdin < "${target}" | \
      grep -P '(ruleAptGetUpdatePrecedesInstall|ruleAptGetInstallUseY|yumInstallForceYes|sha256sumEchoOneSpaces)' |  wc -l >> "${DIR}/results-binnacle.txt"
done <"${DIR}/targets.txt"
echo "  + Finished!"

rm -f "${DIR}/results-hadolint.txt"
touch "${DIR}/results-hadolint.txt"

echo "Running hadolint on broken dockerfiles..."
while read f; do
    target="${DIR}/../data/broken-dockerfiles/$(basename $(dirname $f)).Dockerfile"
    docker run --rm -i hadolint/hadolint < "${target}" | \
        grep -P 'DL(3006|3007|3014|3016|3028)' | wc -l >> "${DIR}/results-hadolint.txt"
done <"${DIR}/targets.txt"
echo "  + Finished!"
