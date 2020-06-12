#!/bin/bash

VERSION=${1:-latest}

docker build colinbruner/homepage:${VERSION} .
