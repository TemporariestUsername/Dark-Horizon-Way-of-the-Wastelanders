#!/usr/bin/env bash
# Build the playtest zips for Windows and macOS (and Linux, for the smoke test), each with
# docs/playtest/PLAYTEST.txt inside. Writes build.txt (the build id shown on the menu and in the
# playtest log) first.
#
#   tools/export.sh                 # all three, into build/
#   BUILD_ID=abc1234 tools/export.sh windows macos
#
# Needs: tools/get_godot.sh and tools/get_export_templates.sh (Linux x86_64).
set -euo pipefail
cd "$(dirname "$0")/.."

GODOT="${GODOT:-$(tools/get_godot.sh)}"
tools/get_export_templates.sh > /dev/null
targets=("$@")
[ ${#targets[@]} -eq 0 ] && targets=(windows macos linux)

id="${BUILD_ID:-$(git rev-parse --short HEAD 2>/dev/null || echo local)}"
echo "$id $(date -u +%Y-%m-%d)" > build.txt
trap 'rm -f build.txt' EXIT   # only the exported builds carry an id; a checkout stays "dev"
name="DarkHorizon-playtest-$id"

rm -rf build && mkdir -p build/out
# Import once so the exports see every script and scene.
timeout 300 "$GODOT" --headless --path . --import > build/import.log 2>&1 || { cat build/import.log; exit 1; }

export_one() {   # preset, output path
  mkdir -p "$(dirname "$2")"
  timeout 600 "$GODOT" --headless --path . --export-release "$1" "$2" > "build/export-$1.log" 2>&1 || true
  if [ ! -s "$2" ] || grep -q "^ERROR" "build/export-$1.log"; then
    cat "build/export-$1.log" >&2
    echo "export $1 failed" >&2
    exit 1
  fi
}

for t in "${targets[@]}"; do
  case "$t" in
    windows)
      export_one Windows build/windows/DarkHorizon.exe
      cp docs/playtest/PLAYTEST.txt build/windows/
      python3 -I - build/windows "build/out/$name-windows.zip" <<'EOF'
import os, sys, zipfile
src, out = sys.argv[1], sys.argv[2]
with zipfile.ZipFile(out, "w", zipfile.ZIP_DEFLATED) as z:
    for f in sorted(os.listdir(src)):
        z.write(os.path.join(src, f), f)
EOF
      ;;
    macos)
      export_one macOS build/macos/export.zip
      # Rename the bundle ("Dark Horizon- Way of the..." from the project name) to "Dark Horizon.app",
      # keeping file modes. The ad-hoc signature covers Contents/, not the bundle's folder name.
      python3 -I - build/macos/export.zip docs/playtest/PLAYTEST.txt "build/out/$name-macos.zip" <<'EOF'
import sys, zipfile
src, readme, out = sys.argv[1], sys.argv[2], sys.argv[3]
with zipfile.ZipFile(src) as zin, zipfile.ZipFile(out, "w", zipfile.ZIP_DEFLATED) as zout:
    for info in zin.infolist():
        top, _, rest = info.filename.partition("/")
        if not top.endswith(".app"):
            raise SystemExit("unexpected entry " + info.filename)
        new = zipfile.ZipInfo("Dark Horizon.app/" + rest, info.date_time)
        new.external_attr = info.external_attr
        new.create_system = 3   # Unix, so the executable bit survives
        new.compress_type = zipfile.ZIP_DEFLATED
        zout.writestr(new, zin.read(info))
    zout.write(readme, "PLAYTEST.txt")
EOF
      ;;
    linux)
      export_one Linux build/linux/DarkHorizon.x86_64
      # The smoke test: the exported build loads the data and writes the playtest log, then quits.
      XDG_DATA_HOME="$PWD/build/smoke-home" timeout 120 build/linux/DarkHorizon.x86_64 --headless -- --smoke-test
      ;;
    *) echo "unknown target $t (windows, macos, linux)" >&2; exit 2 ;;
  esac
done
ls -la build/out
