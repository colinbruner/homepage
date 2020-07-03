#!/bin/bash

# Intended to be run on a Debian variant
ZOLA="v0.11.0"

if ! $(which wget &>/dev/null); then
    echo "Installing wget"
    apt update && apt install -y wget
fi

wget -c https://github.com/getzola/zola/releases/download/${ZOLA}/zola-${ZOLA}-x86_64-unknown-linux-gnu.tar.gz -O - | tar -xz

echo "Creating workspace dir"
mkdir -p workspace

echo "Generating Site"
./zola -r site build

echo "Moving 'public/' into 'workspace/'"
mv public workspace/
