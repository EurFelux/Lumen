#!/bin/bash
set -euo pipefail

# notarize.sh
# Signs, notarizes, and staples Lumen.app for distribution outside the App Store.
# You MUST set your Developer ID Application signing identity below.

# ---------------------------------------------------------------------------
# CONFIGURATION: Replace with your actual Developer ID Application identity
# Find it with: security find-identity -v -p codesigning
# Example: DEVELOPER_ID="Developer ID Application: Your Name (TEAMID)"
# ---------------------------------------------------------------------------
DEVELOPER_ID="Developer ID Application: KEVIN PATRICK KNIGHT (5P2LWPPWRN)"
# ---------------------------------------------------------------------------

APP_PATH="${1:-}"

if [ -z "$APP_PATH" ]; then
    APP_PATH=$(find ~/Library/Developer/Xcode/DerivedData -name "Lumen.app" -type d | head -1)
    if [ -z "$APP_PATH" ]; then
        echo "ERROR: Could not find Lumen.app. Build the project first or pass the path."
        echo "Usage: $0 [path/to/Lumen.app]"
        exit 1
    fi
fi

if [[ "$DEVELOPER_ID" == *"YOUR_NAME_HERE"* ]] || [[ "$DEVELOPER_ID" == *"TEAM_ID_HERE"* ]]; then
    echo "ERROR: You must set DEVELOPER_ID in this script before running."
    echo "Find your identity with: security find-identity -v -p codesigning"
    exit 1
fi

if [ ! -d "$APP_PATH" ]; then
    echo "ERROR: App bundle not found at $APP_PATH"
    exit 1
fi

BINARY_PATH="$APP_PATH/Contents/MacOS/Lumen"
if [ ! -f "$BINARY_PATH" ]; then
    echo "ERROR: Binary not found at $BINARY_PATH"
    exit 1
fi

echo "=== Lumen Notarization Pipeline ==="
echo "App:     $APP_PATH"
echo "Signer:  $DEVELOPER_ID"
echo ""

# --- Step 1: Clean existing signatures ---
echo "[1/4] Removing existing signatures..."
codesign --remove-signature "$APP_PATH" 2>/dev/null || true
echo "      Done"

# --- Step 2: Sign with Developer ID ---
echo ""
echo "[2/4] Signing with Developer ID..."
codesign --force --deep --sign "$DEVELOPER_ID" \
    --entitlements Lumen/Lumen.entitlements \
    --options runtime \
    "$APP_PATH"
echo "      Done"

# --- Step 3: Verify signature ---
echo ""
echo "[3/4] Verifying signature..."
codesign --verify --deep --strict "$APP_PATH"
echo "      Signature valid"

# --- Step 4: Create DMG for notarization ---
echo ""
echo "[4/4] Creating DMG and submitting for notarization..."

TMP_DIR=$(mktemp -d)
DMG_PATH="$TMP_DIR/Lumen.dmg"
VOLUME_NAME="Lumen"

hdiutil create -volname "$VOLUME_NAME" -srcfolder "$APP_PATH" -ov -format UDZO "$DMG_PATH" >/dev/null

echo "      DMG created at $DMG_PATH"
echo ""
echo "Submitting to Apple Notary Service..."
echo "(You may be prompted for your Apple ID app-specific password or keychain profile)"
echo ""

# Option A: Use notarytool with stored credentials profile (recommended)
# xcrun notarytool submit "$DMG_PATH" --keychain-profile "AC_PASSWORD" --wait

# Option B: Use notarytool with Apple ID directly (uncomment if needed)
# xcrun notarytool submit "$DMG_PATH" --apple-id "your@email.com" --team-id "YOUR_TEAM_ID" --password "@keychain:AC_PASSWORD" --wait

# Option C: Use notarytool with API key (for CI/CD)
# xcrun notarytool submit "$DMG_PATH" --key-id "YOUR_KEY_ID" --issuer "YOUR_ISSUER_ID" --wait

echo "---------------------------------------------------------------"
echo "Notarization submission step is a template. Uncomment and configure"
echo "one of the options above in this script, then re-run."
echo ""
echo "After notarization succeeds, staple the ticket:"
echo "  xcrun stapler staple \"$APP_PATH\""
echo "  xcrun stapler staple \"$DMG_PATH\""
echo "---------------------------------------------------------------"

# Cleanup
rm -rf "$TMP_DIR"

echo ""
echo "=== Sign & Package Complete ==="
echo "Next: Uncomment the notarytool command in this script and run again."
