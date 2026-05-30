#!/bin/bash

echo "🔑 Getting your SHA-1 fingerprint for Google Sign-In..."
echo ""

# Get SHA-1 for debug keystore
SHA1=$(keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android 2>/dev/null | grep "SHA1:" | cut -d: -f2- | tr -d ' ')

if [ -z "$SHA1" ]; then
    echo "❌ Could not find debug keystore"
    echo ""
    echo "Please run this command manually:"
    echo "keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android"
    exit 1
fi

echo "✅ Your SHA-1 fingerprint is:"
echo ""
echo "    $SHA1"
echo ""
echo "📝 Next steps:"
echo ""
echo "1. Copy the SHA-1 above"
echo "2. Go to: https://console.firebase.google.com/project/computerstudent-a0511/settings/general"
echo "3. Scroll to 'Your apps' → Android app"
echo "4. Click 'Add fingerprint'"
echo "5. Paste your SHA-1"
echo "6. Click 'Save'"
echo "7. Download the NEW google-services.json"
echo "8. Replace: android/app/google-services.json"
echo ""
echo "Then run: flutter clean && flutter run"
echo ""
