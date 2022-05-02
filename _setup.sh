#!/bin/bash

DEST_PATH=${@:-/tmp}

curl -sL https://raw.githubusercontent.com/fabiodvc/coding-standards/main/.pre-commit-config.yaml \
  -o $DEST_PATH/
curl -sL https://raw.githubusercontent.com/fabiodvc/coding-standards/main/.eslint.yaml \
  -o $DEST_PATH/

echo "..."

pip3 install pre-commit
npm install

echo "..."

echo "# TODO!"
