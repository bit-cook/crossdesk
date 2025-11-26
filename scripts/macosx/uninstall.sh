#!/bin/bash
# macOS uninstall script for CrossDesk
# This script removes the application and cleans up permissions

APP_NAME="CrossDesk"
IDENTIFIER="cn.crossdesk.app"

echo "Uninstalling ${APP_NAME}..."

# Remove application
if [ -d "/Applications/${APP_NAME}.app" ]; then
    echo "Removing application..."
    rm -rf "/Applications/${APP_NAME}.app"
fi

# Remove user data
USER_HOME=$(/usr/bin/stat -f "%Su" /dev/console 2>/dev/null)
if [ -n "$USER_HOME" ]; then
    HOME_DIR=$(/usr/bin/dscl . -read "/Users/$USER_HOME" NFSHomeDirectory 2>/dev/null | awk '{print $2}')
    if [ -n "$HOME_DIR" ]; then
        echo "Removing user data..."
        rm -rf "$HOME_DIR/Library/Application Support/${APP_NAME}"
        rm -rf "$HOME_DIR/Library/Logs/${APP_NAME}"
        rm -rf "$HOME_DIR/Library/Caches/${APP_NAME}"
        rm -rf "$HOME_DIR/Library/Preferences/${IDENTIFIER}.plist"
        rm -rf "$HOME_DIR/Library/LaunchAgents/${APP_NAME}.plist"
    fi
fi

# Remove system-wide certificates
if [ -d "/Library/Application Support/${APP_NAME}/certs" ]; then
    echo "Removing system certificates..."
    rm -rf "/Library/Application Support/${APP_NAME}"
fi

# Clean up permissions using tccutil (macOS 10.14+)
# Note: This requires user interaction and may not work in all cases
if command -v tccutil &> /dev/null; then
    echo "Cleaning up permissions..."
    # Reset screen recording permission
    tccutil reset ScreenCapture "$IDENTIFIER" 2>/dev/null || true
    # Reset accessibility permission
    tccutil reset Accessibility "$IDENTIFIER" 2>/dev/null || true
    # Reset camera permission
    tccutil reset Camera "$IDENTIFIER" 2>/dev/null || true
    # Reset microphone permission
    tccutil reset Microphone "$IDENTIFIER" 2>/dev/null || true
    echo "Permissions cleaned up. You may need to manually remove them from System Settings > Privacy & Security if they still appear."
else
    echo "tccutil not available. Please manually remove permissions from System Settings > Privacy & Security"
fi

echo "Uninstallation complete."
echo ""
echo "Note: If permissions still appear in System Settings, please remove them manually:"
echo "  1. Open System Settings > Privacy & Security"
echo "  2. Remove ${APP_NAME} from Screen Recording and Accessibility"

exit 0

