#!/usr/bin/env sh

if [[ -f ".env" ]]; then source .env; fi
if [[ ! -n $HEALTH_VAULTS_TEAM_ID ]]; then
    echo "HEALTH_VAULTS_TEAM_ID is not set"
    exit 1
fi
export HEALTH_VAULTS_TEAM_ID

if [[ $1 == "-b" || $1 == "--beta"  ]]; then
    echo "Generating for Beta..."
    export DEVELOPER_DIR="/Applications/Xcode-beta.app/Contents/Developer"
else
    echo "Generating for Release..."
    export DEVELOPER_DIR="/Applications/Xcode.app/Contents/Developer"
fi

echo "Building project..."
swift build
echo "Generating project..."
swift run xcodegen
