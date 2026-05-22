#!/bin/bash
set -euo pipefail

# verify-entitlements.sh
# Verifies Lumen.app has correct entitlements, signing, and no private framework links.
# Exits non-zero if any check fails.

APP_PATH="${1:-}"

if [ -z "$APP_PATH" ]; then
    # Auto-detect built app from DerivedData
    APP_PATH=$(find ~/Library/Developer/Xcode/DerivedData -name "Lumen.app" -type d | head -1)
    if [ -z "$APP_PATH" ]; then
        echo "FAIL: Could not find Lumen.app in DerivedData. Please build first or pass the path."
        echo "Usage: $0 [path/to/Lumen.app]"
        exit 1
    fi
fi

BINARY_PATH="$APP_PATH/Contents/MacOS/Lumen"

if [ ! -f "$BINARY_PATH" ]; then
    echo "FAIL: Binary not found at $BINARY_PATH"
    exit 1
fi

FAILED=0

echo "=== Lumen Entitlements & Signing Verification ==="
echo "App: $APP_PATH"
echo ""

# --- Check 1: otool -L for private framework references ---
echo "[1/4] Checking linked libraries (otool -L)..."
OTOOL_OUTPUT=$(otool -L "$BINARY_PATH" 2>&1)

# Check for known private framework names
PRIVATE_FRAMEWORKS=("BezelServices" "SkyLight" "DisplayServices")
PRIVATE_FOUND=""
for fw in "${PRIVATE_FRAMEWORKS[@]}"; do
    if echo "$OTOOL_OUTPUT" | grep -qi "$fw"; then
        PRIVATE_FOUND="$PRIVATE_FOUND $fw"
    fi
done

# Check for @rpath or @loader_path references that aren't standard
NON_STANDARD=$(echo "$OTOOL_OUTPUT" | grep -E '@rpath|@loader_path' | grep -v 'Lumen.debug.dylib' || true)

if [ -n "$PRIVATE_FOUND" ] || [ -n "$NON_STANDARD" ]; then
    echo "  FAIL: Private or non-standard framework references detected"
    if [ -n "$PRIVATE_FOUND" ]; then
        echo "  -> Private frameworks:$PRIVATE_FOUND"
    fi
    if [ -n "$NON_STANDARD" ]; then
        echo "  -> Non-standard @rpath/@loader_path:"
        echo "$NON_STANDARD" | sed 's/^/     /'
    fi
    FAILED=1
else
    echo "  OK    No private framework references found"
fi

# --- Check 2: codesign --verify --deep --strict ---
echo ""
echo "[2/4] Verifying code signature (codesign --verify --deep --strict)..."
if codesign --verify --deep --strict "$APP_PATH" 2>&1; then
    echo "  OK    Code signature is valid"
else
    echo "  FAIL  Code signature verification failed"
    FAILED=1
fi

# --- Check 3: spctl --assess --type execute ---
echo ""
echo "[3/4] Assessing Gatekeeper approval (spctl --assess --type execute)..."
if spctl --assess --type execute "$APP_PATH" 2>&1; then
    echo "  OK    Gatekeeper assessment passed"
else
    echo "  WARN  Gatekeeper assessment failed (expected for ad-hoc signed debug builds)"
    # Do not fail on spctl for debug builds since they use ad-hoc signing
fi

# --- Check 4: Entitlements check ---
echo ""
echo "[4/4] Checking entitlements..."
ENTITLEMENTS_XML=$(codesign -d --entitlements :- "$APP_PATH" 2>&1 || true)

if echo "$ENTITLEMENTS_XML" | grep -q "com.apple.security.cs.disable-library-validation"; then
    echo "  OK    disable-library-validation entitlement present"
else
    echo "  FAIL  disable-library-validation entitlement missing"
    FAILED=1
fi

if echo "$ENTITLEMENTS_XML" | grep -qi "com.apple.security.app-sandbox"; then
    echo "  FAIL  App Sandbox entitlement present (must NOT be present)"
    FAILED=1
else
    echo "  OK    No App Sandbox entitlement"
fi

echo ""
echo "========================================"
if [ "$FAILED" -eq 0 ]; then
    echo "Result: ALL CHECKS PASSED"
    exit 0
else
    echo "Result: ONE OR MORE CHECKS FAILED"
    exit 1
fi
