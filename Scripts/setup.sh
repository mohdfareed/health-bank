#!/usr/bin/env zsh

echo "Generating project..."
swift run xcodegen

echo

echo "Generating app icon..."
./Scripts/assets.py
