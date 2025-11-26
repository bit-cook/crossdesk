#!/bin/bash
# Helper script to sign macOS app with different certificate options
# Usage: ./sign_app.sh <app_path> [certificate_name]

APP_PATH="$1"
CERT_NAME="$2"

if [ -z "$APP_PATH" ]; then
    echo "Usage: $0 <app_path> [certificate_name]"
    echo ""
    echo "Examples:"
    echo "  $0 CrossDesk.app                    # Ad-hoc signing"
    echo "  $0 CrossDesk.app \"CrossDesk Dev\"   # Sign with certificate name"
    echo "  $0 CrossDesk.app \"-\"               # Explicit ad-hoc signing"
    exit 1
fi

if [ ! -d "$APP_PATH" ]; then
    echo "Error: App bundle not found: $APP_PATH"
    exit 1
fi

if [ -z "$CERT_NAME" ]; then
    # Default to ad-hoc signing
    CERT_NAME="-"
    echo "Using ad-hoc signing (no certificate specified)"
else
    echo "Using certificate: $CERT_NAME"
fi

# Check if codesign is available
if ! command -v codesign &> /dev/null; then
    echo "Error: codesign not found. Please install Xcode Command Line Tools."
    exit 1
fi

# Sign the app
echo "Signing $APP_PATH..."
codesign --force --deep --sign "$CERT_NAME" "$APP_PATH"

if [ $? -eq 0 ]; then
    echo "Signing successful!"
    
    # Verify signature
    echo ""
    echo "Verifying signature..."
    codesign -dv --verbose=4 "$APP_PATH" 2>&1 | head -20
    
    echo ""
    echo "Checking entitlements..."
    codesign -d --entitlements - "$APP_PATH" 2>&1 || echo "No entitlements found"
else
    echo "Error: Signing failed"
    exit 1
fi

