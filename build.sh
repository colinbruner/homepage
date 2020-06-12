#!/bin/bash

VERSION=${1:-latest}

docker build -t colinbruner/homepage:${VERSION} .
