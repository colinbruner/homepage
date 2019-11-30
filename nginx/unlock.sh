#!/bin/bash

echo "unlocking key.pem"
gpg -o keypem -d key.pem.gpg

echo "unlocking cert.pem"
gpg -o cert.pem -d cert.pem.gpg
