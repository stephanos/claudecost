#!/usr/bin/env bash
set -euo pipefail

configuration="${1:-debug}"
app_dir=".build/${configuration}/AgentTally.app"
contents_dir="${app_dir}/Contents"
macos_dir="${contents_dir}/MacOS"
frameworks_dir="${contents_dir}/Frameworks"
executable=".build/${configuration}/AgentTally"
plist_path="${contents_dir}/Info.plist"
codesign_identity="${CODESIGN_IDENTITY:--}"
sparkle_framework="$(
  find .build/artifacts/sparkle/Sparkle/Sparkle.xcframework \
    -type d \
    -name Sparkle.framework \
    -print \
    -quit 2>/dev/null
)"

if [[ ! -x "${executable}" ]]; then
  echo "missing executable: ${executable}" >&2
  exit 1
fi

if [[ -z "${sparkle_framework}" || ! -d "${sparkle_framework}" ]]; then
  echo "missing Sparkle.framework; run swift package resolve/build first" >&2
  exit 1
fi

rm -rf "${app_dir}"
mkdir -p "${macos_dir}" "${frameworks_dir}"

cp "${executable}" "${macos_dir}/AgentTally"
ditto "${sparkle_framework}" "${frameworks_dir}/Sparkle.framework"
bash scripts/generate_info_plist.sh "${plist_path}"

codesign --force --sign "${codesign_identity}" "${macos_dir}/AgentTally"
codesign --force --sign "${codesign_identity}" "${app_dir}"
