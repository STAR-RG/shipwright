#!/bin/bash

#set -ex
HERE="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
LOG_DIR="${HERE}/OUTPUT"
mkdir -p "$LOG_DIR"
project=$1
if [ -z "$1" ]; then
    echo "Unrecognized option"
    echo "use ./shipwright.sh {project_folder}"
    exit 1
fi
if [ ! -d "$project" ]; then
    echo "folder $project not exist"
    exit 2
fi

echo "building Dockerfile. Please wait"
cd "$project"
    docker build . > out.log 2> error.log

    if [[ ! -s error.log ]]; then 
        echo "WARNING: there are probably no errors in the dockerfile"; 
    fi
    if [[ ! -s out.log ]]; then 
        echo "WARNING: there is probably no Dockerfile in the folder"; 
    fi
cd ..

echo "Running shipwright. Please wait"
cd src
    python3 s.py $project
cd ..


