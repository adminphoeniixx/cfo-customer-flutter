#!/usr/bin/env bash
# Builds an App Store IPA without needing a registered device.
# The archive is built unsigned, then signed with the App Store (Team Store)
# profile at export time, which Xcode creates via -allowProvisioningUpdates.
#
# Usage: scripts/build_ios_ipa.sh [build-name] [build-number]
#   build-name must match the version in App Store Connect (default 1.0).
set -euo pipefail

cd "$(dirname "$0")/.."

BUILD_NAME="${1:-1.0}"
BUILD_NUMBER="${2:-2}"
ARCHIVE=build/ios/archive/Runner.xcarchive

flutter build ios --release --no-codesign \
  --build-name="$BUILD_NAME" --build-number="$BUILD_NUMBER"

rm -rf "$ARCHIVE" build/ios/ipa
xcodebuild -workspace ios/Runner.xcworkspace -scheme Runner \
  -configuration Release -destination 'generic/platform=iOS' \
  -archivePath "$ARCHIVE" archive \
  CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO

xcodebuild -exportArchive -archivePath "$ARCHIVE" \
  -exportPath build/ios/ipa -exportOptionsPlist ios/ExportOptions.plist \
  -allowProvisioningUpdates

echo "IPA ready: build/ios/ipa/"
