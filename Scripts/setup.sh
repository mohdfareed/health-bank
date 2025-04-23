#!/usr/bin/env zsh

echo "Generating project..."
swift run xcodegen

echo

echo "Generating assets..."
./Scripts/assets.py
