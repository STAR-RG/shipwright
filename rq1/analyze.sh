#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

TOTAL_BUILT_FILES=$(
    ls "${DIR}/../data/build-results/" | wc -l | awk '{print $1}'
)

TOTAL_BROKEN_FILES=$(
    cat "${DIR}/results-hadolint.txt" | \
    wc -l | awk '{print $1}'
)

printf "Overall build breakage rate: %.1f%%\n" \
  $(echo "${TOTAL_BROKEN_FILES}.0/${TOTAL_BUILT_FILES}.0*100.0" | bc -l)

BINNACLE_CAUGHT=$(
    cat "${DIR}/results-binnacle.txt" | \
    grep -v '0' | wc -l | awk '{print $1}'
)

HADOLINT_CAUGHT=$(
    cat "${DIR}/results-hadolint.txt" | \
    grep -v '0' | wc -l | awk '{print $1}'
)

printf "Binnacle detects: %.1f%% of possible build-breaking issues.\n" \
  $(echo "${BINNACLE_CAUGHT}.0/${TOTAL_BROKEN_FILES}.0*100.0" | bc -l)
printf "Hadolint detects: %.1f%% of possible build-breaking issues.\n" \
  $(echo "${HADOLINT_CAUGHT}.0/${TOTAL_BROKEN_FILES}.0*100.0" | bc -l)
