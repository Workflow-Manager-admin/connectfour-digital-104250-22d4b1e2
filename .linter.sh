#!/bin/bash
cd /home/kavia/workspace/code-generation/connectfour-digital-104250-22d4b1e2/connectfour_digital
npm run lint
ESLINT_EXIT_CODE=$?
npm run build
BUILD_EXIT_CODE=$?
if [ $ESLINT_EXIT_CODE -ne 0 ] || [ $BUILD_EXIT_CODE -ne 0 ]; then
   exit 1
fi

