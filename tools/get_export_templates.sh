#!/usr/bin/env bash
# Download the official Godot 4.4.1 export templates, verify the archive's SHA-512 against the
# release checksums, and install only the templates the playtest builds use (Windows, macOS,
# and Linux for the CI smoke test). Prints the install directory.
#
#   tools/get_export_templates.sh   # then: "$GODOT" --headless --path . --export-release "Windows" build/...
#
# The archive is 1.2 GB; what's kept is a few hundred MB. Linux x86_64 (CI and cloud sessions).
set -euo pipefail

VERSION="4.4.1-stable"
FILE="Godot_v${VERSION}_export_templates.tpz"
URL="https://github.com/godotengine/godot/releases/download/${VERSION}"
DEST="${XDG_DATA_HOME:-$HOME/.local/share}/godot/export_templates/${VERSION/-/.}"
KEEP=(version.txt windows_release_x86_64.exe macos.zip linux_release.x86_64)

if [ -f "$DEST/version.txt" ] && [ -f "$DEST/windows_release_x86_64.exe" ] && [ -f "$DEST/macos.zip" ] && [ -f "$DEST/linux_release.x86_64" ]; then
  echo "$DEST"
  exit 0
fi

mkdir -p "$DEST"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
fetch() { curl -fsSL --retry 5 --retry-all-errors --retry-delay 3 -o "$1" "$2"; }
fetch "$tmp/SHA512-SUMS.txt" "$URL/SHA512-SUMS.txt"
fetch "$tmp/$FILE" "$URL/$FILE"
expected="$(grep " $FILE\$" "$tmp/SHA512-SUMS.txt" | cut -d' ' -f1)"
actual="$(sha512sum "$tmp/$FILE" | cut -d' ' -f1)"
if [ -z "$expected" ] || [ "$expected" != "$actual" ]; then
  echo "Export templates failed their checksum" >&2
  exit 1
fi
python3 -I - "$tmp/$FILE" "$DEST" "${KEEP[@]}" <<'EOF'
import os, shutil, sys, zipfile
src, dest, keep = sys.argv[1], sys.argv[2], sys.argv[3:]
with zipfile.ZipFile(src) as z:
    for name in keep:
        with z.open("templates/" + name) as f, open(os.path.join(dest, name), "wb") as out:
            shutil.copyfileobj(f, out)
EOF
chmod +x "$DEST/linux_release.x86_64"
echo "$DEST"
