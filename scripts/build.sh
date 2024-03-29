#!/bin/bash

# Intended to be run on a Debian variant
ZOLA="v0.14.0"
ARCH=$(uname)

# Get abs path of script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

function msg() {
    # Lazy stdout message generator
    echo "##########################"
    echo "# ${1}"
    echo "##########################"
}

function clean() {
    echo "Cleaning the 'site/public' dir"
    rm -rf site/public
}

function init() {
    # Install Zola on Linux
    if [[ $ARCH == 'Linux' ]]; then
        if ! $(which pip3 &>/dev/null); then
            echo "Installing pip3"
            sudo apt update -y && sudo apt install -y python3-pip
        fi

        if ! $(which zola &>/dev/null); then
            echo "Downloading Zola"
            wget -c https://github.com/getzola/zola/releases/download/${ZOLA}/zola-${ZOLA}-x86_64-unknown-linux-gnu.tar.gz -O - | tar -xz
            export PATH="$PATH:$PWD"
        fi

        if ! $(which aws &>/dev/null); then
            echo "Downloading awscli"
            pip3 install awscli --upgrade --user
        fi
    fi
}


function main() {
    # Build environment to pass to Zola... default production
    export ZOLA_ENV="${ZOLA_ENV:-production}"

    # Assume zola is already installed in PATH on Darwin...
    msg "Generating Site"
    cd ${SCRIPT_DIR}/.. && zola build

    msg "Syncing public/processed_images/ images to s3://media.colinbruner.com/processed_images/"
    aws s3 sync public/processed_images s3://media.colinbruner.com/processed_images/

    msg "Removing all local non-processed images"
    find public -type f \( -iname "*.png" -o -iname "*.webp" \) -exec rm -f {} \;

    if [[ $ZOLA_ENV != "production" ]]; then
        msg "Syncing site to development bucket: s3://development.colinbruner.com"
        aws s3 sync public s3://development.colinbruner.com
    else
        msg "Syncing site to production bucket: s3://colinbruner.com"
        aws s3 sync public s3://colinbruner.com
    fi
}

# Clean any leftover files / artifacts
clean

# If being executed in a Linux environment "docker container" install necessary tools.
init

# Build & Sync site to s3
main
