#!/bin/bash

echo "unlocking colinbruner.key"
gpg -o colinbruner.key -d colinbruner.key.gpg

echo "unlocking colinbruner.pem"
gpg -o colinbruner.pem -d colinbruner.pem.gpg
