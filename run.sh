#!/bin/bash

VERSION=${1:-latest}
ARCH=$(uname -m)

if [[ "$ARCH" =~ "arm"* ]]; then
        # run arm, if arm... else just run latest or $1
        VERSION="arm"
fi

# Local development/testing
docker run \
        --rm \
	-it \
        -p 80:80 \
        -p 443:443 \
        colinbruner/homepage:${VERSION}
