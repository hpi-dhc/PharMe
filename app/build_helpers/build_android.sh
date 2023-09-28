#!/bin/bash

# Run this from the app project root
# Receives path to keystore and path to repository as parameters

output_path="app/build/app/outputs/bundle/release"
docker build -f build_helpers/android.Dockerfile -t build-pharme-for-android .
docker run \
    -v $1:/keystore \
    -v $2/$output_path:/$output_path \
    build-pharme-for-android \
    flutter build appbundle
