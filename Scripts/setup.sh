#!/usr/bin/env zsh

echo "Setting up project scripts..."
chmod +x Scripts/*
echo "Generating Xcode project..."
swift run xcodegen
