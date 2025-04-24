#!/usr/bin/env zsh

echo "Generating app icon..."
./Scripts/app_icon.swift

echo "Generating assets..."
./Scripts/assets.py

echo "Building app..."
swift build
