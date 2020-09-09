#!/bin/bash

# Intended to be run on a Debian variant
ZOLA="v0.11.0"
ARCH=$(uname)

echo "Cleaning then && creating workspace dir"
rm -rf workspace && mkdir -p workspace

if [[ $ARCH == 'Linux' ]]; then
    if ! $(which wget &>/dev/null); then
        echo "Installing wget"
        apt update && apt install -y wget
    fi

    echo "Downloading Zola binary"
    wget -c https://github.com/getzola/zola/releases/download/${ZOLA}/zola-${ZOLA}-x86_64-unknown-linux-gnu.tar.gz -O - | tar -xz
    echo "Generating Site"
    ./zola -r site build
else
    # Assume zola is already installed in PATH on Darwin...
    echo "Generating Site"
    zola -r site build
fi

echo "Moving 'public/' into 'workspace/'"
mv public workspace/
find workspace/public -name "*.png" -exec rm -f {} \;
