#!/usr/bin/env zsh

echo "Generating Xcode project..."
swift run xcodegen
echo "Running tests..."
swift test
