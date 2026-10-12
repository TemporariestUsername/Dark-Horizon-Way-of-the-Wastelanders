#!/usr/bin/env bash
# Download the pinned Godot build used by the M1 sim and tests, verify its SHA-512
# against the official release checksums, and print the binary's path.
#
#   GODOT=$(tools/get_godot.sh)   # then: "$GODOT" --headless --path . --script res://tests/run_tests.gd
#
# Linux x86_64 only (CI and cloud sessions). On Windows or macOS, install Godot 4.4.1 normally.
set -euo pipefail

VERSION="4.4.1-stable"
FILE="Godot_v${VERSION}_linux.x86_64"
URL="https://github.com/godotengine/godot/releases/download/${VERSION}"
DIR="${GODOT_DIR:-${XDG_CACHE_HOME:-$HOME/.cache}/dark-horizon/godot-${VERSION}}"

if [ -x "$DIR/$FILE" ]; then
  echo "$DIR/$FILE"
  exit 0
fi

mkdir -p "$DIR"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
curl -fsSL -o "$tmp/$FILE.zip" "$URL/$FILE.zip"
curl -fsSL -o "$tmp/SHA512-SUMS.txt" "$URL/SHA512-SUMS.txt"
expected="$(grep " $FILE.zip\$" "$tmp/SHA512-SUMS.txt" | cut -d' ' -f1)"
actual="$(sha512sum "$tmp/$FILE.zip" | cut -d' ' -f1)"
if [ -z "$expected" ] || [ "$expected" != "$actual" ]; then
  echo "Godot download failed its checksum" >&2
  exit 1
fi
python3 -I -c "import sys, zipfile; zipfile.ZipFile(sys.argv[1]).extractall(sys.argv[2])" "$tmp/$FILE.zip" "$DIR"
chmod +x "$DIR/$FILE"
echo "$DIR/$FILE"
