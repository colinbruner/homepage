#!/bin/bash -e

BRANCH=$(git symbolic-ref --short HEAD)

if [[ -f "workspace/public" ]]; then
    cd workspace/public
    aws s3 sync . s3://s3.colinbruner.com/
else
    echo "Current path: $(PWD)"
    echo "Unable to find site/workspace/public directory. Were site assets generated?"
fi
