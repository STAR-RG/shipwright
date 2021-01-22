#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

CMD="echo 'unknown arguments: $@'"

if [ "${1}" == "run-rq1" ]; then
    CMD="/app/rq1/analyze.sh"
elif [ "${1}" == "run-rq2" ]; then
    CMD="/app/rq2/clustering.py"
elif [ "${1}" == "run-rq2-do-clustering" ]; then
    CMD="/app/rq2/clustering.py --do-clustering"
elif [ "${1}" == "run-rq3" ]; then
    CMD="python3 /app/rq3/shipwright.py clustered ; python3 /app/rq3/shipwright.py non-clustered"
elif [ "${1}" == "extract" ]; then
    CMD="/app/data/raw-build-results/extract.sh"
else
    echo "Unrecognized options: '$@'"
    echo "  + Use './shipwright.sh extract' to extract ./data/raw-build-results to ./data/build-results"
    echo "  + Use './shipwright.sh run-rq1' to run scripts for rq1."
    echo "  + Use './shipwright.sh run-rq2' to run scripts for rq2."
    echo "  + Use './shipwright.sh run-rq2-do-clustering' to run scripts for rq2 including clustering (WARNING: this is slow)."
    echo "  + Use './shipwright.sh run-rq3' to run scripts for rq3."
    echo "  + Otherwise, see './rq4/README.md' for a breakdown of our pull requests (PRs)."
    exit 1
fi

set -ex
docker run -it --rm \
  --entrypoint bash \
  -v "${DIR}":/app \
  jjhenkel/shipwright:latest \
    -c "${CMD}"
