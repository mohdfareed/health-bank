#!/usr/bin/env sh

if [[ -f ".env" ]]; then source .env; fi
if [[ ! -n $HEALTH_BANK_TEAM_ID ]]; then
    echo "HEALTH_BANK_TEAM_ID is not set"
    exit 1
fi
export HEALTH_BANK_TEAM_ID

echo "Generating project..."
swift run xcodegen
