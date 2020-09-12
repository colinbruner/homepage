#!/bin/bash -e

BRANCH=$(git symbolic-ref --short HEAD)

if ! $(which aws &>/dev/null); then
    # We'll assume the running image has `pip` installed
    pip3 install awscli --upgrade --user
fi

# The generated public directory gets mounted in the root of this directory under
# a 'workspace/' directory after the generate site stage of circleci
if [[ -d "workspace/public/" ]]; then
    cd workspace/public/
    aws s3 sync . s3://s3.colinbruner.com/
else
    echo "Current path: $PWD"
    echo "Unable to find workspace/public directory. Were site assets generated?"
fi

