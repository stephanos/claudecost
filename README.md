# AgentTally

[![release](https://img.shields.io/github/v/release/stephanos/agenttally-macos)](https://github.com/stephanos/agenttally-macos/releases/latest)

`AgentTally` is a standalone macOS menu bar app for tracking AI agent spending.

The app shows Claude Code and Codex spend for today and the current month.

<p align="center">
  <img src="docs/menu-bar.png" alt="AgentTally menu bar screenshot" width="420">
</p>

## Install

1. Download [`AgentTally.dmg`](https://github.com/stephanos/agenttally-macos/releases/latest)
2. Open the disk image
3. Drag `AgentTally.app` to `/Applications`
4. Open `AgentTally.app`

On first launch, macOS may ask you to confirm opening the app.
If macOS warns that the app cannot be opened because it cannot check it for malware, remove the quarantine attribute and open it again:

```sh
xattr -dr com.apple.quarantine /Applications/AgentTally.app
```

## Development

To build from source, you need:

- `mise`

From this directory:

```sh
mise trust
mise install
mise run install
```

The install task copies the bundle to `/Applications/AgentTally.app` and launches it.

For local development:

```sh
mise run dev
```

## Releases

To cut a new release:

```sh
mise run check
git tag -a v0.10 -m "v0.10"
git push origin v0.10
```

Pushing the tag runs the GitHub Actions release workflow, which builds the app,
uploads `AgentTally.dmg`, publishes `appcast.xml`, and makes the release available to Sparkle.
