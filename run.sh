#!/bin/bash

VERSION=${1:-latest}
ARCH=$(uname -m)

if [[ "$ARCH" =~ "arm"* ]]; then
        # run arm, if arm... else just run latest or $1
        VERSION="arm"
fi

# brute force
docker stop homepage &>/dev/null && docker rm homepage &>/dev/null

docker container run \
        -p 443:443 \
        -p 80:80 \
        --name "homepage" \
        cbruner/homepage:${VERSION}
