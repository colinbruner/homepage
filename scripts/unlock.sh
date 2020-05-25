#!/bin/bash

echo "unlocking key.pem"
gpg -o key.pem -d nginx/key.pem.gpg

echo "unlocking cert.pem"
gpg -o cert.pem -d nginx/cert.pem.gpg
