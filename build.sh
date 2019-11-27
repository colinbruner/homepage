#!/bin/bash

VERSION=${1:-latest}
ARCH=$(uname -m)

if [[ "$ARCH" =~ "arm"* ]]; then
    #docker build --no-cache -f Dockerfile.arm -t cbruner/homepage:arm .
    docker build -f Dockerfile.arm -t cbruner/homepage:arm .
    docker build -f Dockerfile.arm -t cbruner/homepage:$VERSION .
else
    docker build --no-cache -f Dockerfile -t cbruner/homepage:$VERSION .
fi
