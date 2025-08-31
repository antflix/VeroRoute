#!/bin/bash

# Simple launcher script for VeroRoute
# This script runs VeroRoute from the built app bundle

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_BUNDLE="$SCRIPT_DIR/VeroRoute.app"

if [[ ! -d "$APP_BUNDLE" ]]; then
    echo "Error: VeroRoute.app not found. Please run ./build-macos.sh first."
    exit 1
fi

echo "Launching VeroRoute..."
open "$APP_BUNDLE" "$@"