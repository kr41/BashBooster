#!/usr/bin/env bash

unset CDPATH
cd "$( dirname "${BASH_SOURCE[0]}" )"


RELEASE="bashbooster-$( cat VERSION.txt )"


[[ ! -d 'dist' ]] && mkdir 'dist'
[[ -f "dist/$RELEASE.zip" ]] && rm "dist/$RELEASE.zip"
[[ -d "dist/$RELEASE" ]] && rm -rf "dist/$RELEASE"


cp -r 'build/' "dist/$RELEASE/"
cp *.txt "dist/$RELEASE"
cp *.md "dist/$RELEASE"


cd dist
zip "$RELEASE.zip" $RELEASE/*
rm -rf "$RELEASE"
