#!/bin/bash

if [ "$1" = "debug" ]; then
    echo "Switching to Debug configuration..."
    cp NowFocus/GoogleService-Info-Debug.plist NowFocus/GoogleService-Info.plist
    echo "✅ Switched to Debug configuration"
elif [ "$1" = "release" ]; then
    echo "Switching to Release configuration..."
    cp NowFocus/GoogleService-Info-Release.plist NowFocus/GoogleService-Info.plist
    echo "✅ Switched to Release configuration"
else
    echo "Usage: ./switch-firebase-config.sh [debug|release]"
    echo "Example: ./switch-firebase-config.sh debug"
    echo "Example: ./switch-firebase-config.sh release"
fi 