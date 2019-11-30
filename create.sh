#!/bin/bash

#--no-resolve-image
docker service create \
    --name homepage \
    --replicas 5 \
    --replicas-max-per-node 1 \
    -p "80:80" \
    -p "443:443" \
    cbruner/homepage:arm
