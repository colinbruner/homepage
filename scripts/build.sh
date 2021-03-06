#!/bin/bash

# Intended to be run on a Debian variant
ZOLA="v0.12.0"
ARCH=$(uname)

echo "Cleaning the 'site/public' dir"
rm -rf site/public

# Install Zola on Linux
if [[ $ARCH == 'Linux' ]]; then
    if ! $(which wget &>/dev/null); then
        echo "Installing wget"
        apt update -y && apt install -y wget
    fi

    if ! $(which zola &>/dev/null); then
        echo "Downloading Zola binary"
        wget -c https://github.com/getzola/zola/releases/download/${ZOLA}/zola-${ZOLA}-x86_64-unknown-linux-gnu.tar.gz -O - | tar -xz
        export PATH="$PATH:$PWD"
    fi

fi

# Assume zola is already installed in PATH on Darwin...
echo "Generating Site"
cd site && zola build

# Remove high def images from travel
echo "Removing non-processed images"
find public/travel -name "*.png" -exec rm -f {} \;
