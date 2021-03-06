#!/bin/bash

branch=$(git symbolic-ref --short -q HEAD)

if ! $(which aws &>/dev/null); then
    # We'll assume the running image has `pip3` installed
    pip3 install awscli --upgrade --user
fi

# The generated public directory gets attached to the root repo directory under
# 'workspace/' after the generate site stage of circleci has completed.
if [[ -d "workspace/public/" ]]; then
    cd workspace/public/
    echo "Syncing to s3 bucket ${branch}.colinbruner.com"
    # Sync diffs up to the appropriate directory
    aws s3 sync . s3://${branch}.colinbruner.com
else
    echo "Unable to find workspace/public directory... Were site assets generated?"
fi

