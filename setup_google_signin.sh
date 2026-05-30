#!/bin/bash

# Script to help configure Google Sign-In for iOS
# This script extracts the REVERSED_CLIENT_ID from Firebase project

echo "🔍 Checking for REVERSED_CLIENT_ID in GoogleService-Info.plist..."
echo ""

PLIST_PATH="ios/Runner/GoogleService-Info.plist"

if [ ! -f "$PLIST_PATH" ]; then
    echo "❌ GoogleService-Info.plist not found at $PLIST_PATH"
    echo "Please download it from Firebase Console and place it in ios/Runner/"
    exit 1
fi

# Check if REVERSED_CLIENT_ID exists in the plist
if grep -q "REVERSED_CLIENT_ID" "$PLIST_PATH"; then
    REVERSED_CLIENT_ID=$(grep -A1 "REVERSED_CLIENT_ID" "$PLIST_PATH" | tail -n1 | sed 's/.*<string>\(.*\)<\/string>.*/\1/')
    echo "✅ REVERSED_CLIENT_ID found: $REVERSED_CLIENT_ID"
    echo ""
    echo "📝 Make sure this URL scheme is in your Info.plist:"
    echo "   $REVERSED_CLIENT_ID"
else
    echo "⚠️  REVERSED_CLIENT_ID not found in GoogleService-Info.plist"
    echo ""
    echo "📋 Follow these steps:"
    echo "1. Go to Firebase Console: https://console.firebase.google.com"
    echo "2. Select your project: computerstudent-a0511"
    echo "3. Go to Project Settings → Your Apps → iOS App"
    echo "4. Download the latest GoogleService-Info.plist"
    echo "5. Replace the file at: ios/Runner/GoogleService-Info.plist"
    echo ""
    echo "The new file should contain the REVERSED_CLIENT_ID key."
fi

echo ""
echo "🔑 For Android Google Sign-In, you need SHA-1 fingerprint:"
echo ""
echo "Run this command to get your debug SHA-1:"
echo "keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android"
echo ""
echo "Then add it to Firebase Console:"
echo "Project Settings → Your Apps → Android App → Add fingerprint"
