#!/usr/bin/env zsh

echo "Generating Xcode project..."
swift run xcodegen
echo "Building app..."
swift build
