#!/usr/bin/env bash
set -euo pipefail

version="${AGENTTALLY_VERSION:-0.0.0-dev}"
plist_path="${1:?output plist path required}"
sparkle_feed_url="${SPARKLE_FEED_URL:-https://github.com/stephanos/agenttally-macos/releases/latest/download/appcast.xml}"
sparkle_public_ed_key="${SPARKLE_PUBLIC_ED_KEY:-NUtyqJx9cL1Uf2b9gHKY3SzJbp/aizxf46tYylyIBBI=}"

cat >"${plist_path}" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleDevelopmentRegion</key>
  <string>en</string>
  <key>CFBundleExecutable</key>
  <string>AgentTally</string>
  <key>CFBundleIdentifier</key>
  <string>dev.stephanos.agenttally</string>
  <key>CFBundleInfoDictionaryVersion</key>
  <string>6.0</string>
  <key>CFBundleName</key>
  <string>AgentTally</string>
  <key>CFBundlePackageType</key>
  <string>APPL</string>
  <key>CFBundleShortVersionString</key>
  <string>${version}</string>
  <key>CFBundleVersion</key>
  <string>${version}</string>
  <key>LSMinimumSystemVersion</key>
  <string>13.0</string>
  <key>LSUIElement</key>
  <true/>
  <key>SUAllowsAutomaticUpdates</key>
  <false/>
  <key>SUAutomaticallyUpdate</key>
  <false/>
  <key>SUEnableAutomaticChecks</key>
  <true/>
  <key>SUFeedURL</key>
  <string>${sparkle_feed_url}</string>
  <key>SUPublicEDKey</key>
  <string>${sparkle_public_ed_key}</string>
  <key>SUScheduledCheckInterval</key>
  <integer>86400</integer>
</dict>
</plist>
EOF
