#!/usr/bin/env bash
set -euo pipefail

tag_name="${1:-${GITHUB_REF_NAME:-}}"
version="${tag_name#v}"
release_dir=".build/release"
app_bundle="${release_dir}/AgentTally.app"
dmg_staging_dir="${release_dir}/dmg"
archive_path="${release_dir}/AgentTally.dmg"
checksum_path="${release_dir}/AgentTally.dmg.sha256"
appcast_dir=".build/appcast/${tag_name}"
appcast_output="${appcast_dir}/appcast.xml"
appcast_path="${release_dir}/appcast.xml"
sparkle_generate_appcast=".build/artifacts/sparkle/Sparkle/bin/generate_appcast"
default_sparkle_private_ed_key_file="sparkle_private_key"
download_url_prefix="https://github.com/stephanos/agenttally-macos/releases/download/${tag_name}/"

if [[ -z "${tag_name}" ]]; then
  echo "release tag is required" >&2
  exit 1
fi

if [[ ! "${tag_name}" =~ ^v[0-9].* ]]; then
  echo "release tag must start with 'v' (for example: v0.5)" >&2
  exit 1
fi

mise trust -y mise.toml
mise install
AGENTTALLY_VERSION="${version}" mise run check

rm -rf "${dmg_staging_dir}" "${archive_path}" "${checksum_path}"
mkdir -p "${dmg_staging_dir}"
ditto "${app_bundle}" "${dmg_staging_dir}/AgentTally.app"
ln -s /Applications "${dmg_staging_dir}/Applications"
hdiutil create \
  -volname "AgentTally" \
  -srcfolder "${dmg_staging_dir}" \
  -ov \
  -format UDZO \
  "${archive_path}"
shasum -a 256 "${archive_path}" > "${checksum_path}"

if [[ ! -x "${sparkle_generate_appcast}" ]]; then
  echo "missing Sparkle generate_appcast tool: ${sparkle_generate_appcast}" >&2
  exit 1
fi

rm -rf "${appcast_dir}"
mkdir -p "${appcast_dir}"
cp "${archive_path}" "${appcast_dir}/AgentTally.dmg"
appcast_args=(
  --download-url-prefix "${download_url_prefix}"
  --link "https://github.com/stephanos/agenttally-macos"
  --maximum-deltas 0
  -o "${appcast_output}"
  "${appcast_dir}"
)
if [[ -n "${SPARKLE_PRIVATE_ED_KEY:-}" ]]; then
  printf "%s" "${SPARKLE_PRIVATE_ED_KEY}" \
    | "${sparkle_generate_appcast}" --ed-key-file - "${appcast_args[@]}"
elif [[ -n "${SPARKLE_PRIVATE_ED_KEY_FILE:-}" ]]; then
  "${sparkle_generate_appcast}" --ed-key-file "${SPARKLE_PRIVATE_ED_KEY_FILE}" "${appcast_args[@]}"
elif [[ -f "${default_sparkle_private_ed_key_file}" ]]; then
  "${sparkle_generate_appcast}" --ed-key-file "${default_sparkle_private_ed_key_file}" "${appcast_args[@]}"
else
  "${sparkle_generate_appcast}" "${appcast_args[@]}"
fi
cp "${appcast_output}" "${appcast_path}"

gh release create "${tag_name}" \
  "${archive_path}" \
  "${checksum_path}" \
  "${appcast_path}" \
  --generate-notes
