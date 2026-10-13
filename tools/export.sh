#!/usr/bin/env bash
# Build the playtest zips for Windows and macOS (and Linux, for the smoke test), each with
# docs/playtest/PLAYTEST.txt inside. Writes build.txt (the build id shown on the menu and in the
# playtest log) first.
#
#   tools/export.sh                 # all three, into build/
#   BUILD_ID=abc1234 tools/export.sh windows macos
#   tools/export.sh macos-arm64 macos-x86_64   # one-architecture Macs, half the size (to send directly)
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
      mkdir -p build/windows/licenses && cp game/fonts/OFL-*.txt build/windows/licenses/
      python3 -I - build/windows "build/out/$name-windows.zip" <<'EOF'
import os, sys, zipfile
src, out = sys.argv[1], sys.argv[2]
with zipfile.ZipFile(out, "w", zipfile.ZIP_DEFLATED, compresslevel=9) as z:
    for d, _, fs in sorted(os.walk(src)):
        for f in sorted(fs):
            path = os.path.join(d, f)
            z.write(path, os.path.relpath(path, src))
EOF
      ;;
    macos)
      export_one macOS build/macos/export.zip
      # Rename the bundle ("Dark Horizon- Way of the..." from the project name) to "Dark Horizon.app",
      # keeping file modes. The ad-hoc signature covers Contents/, not the bundle's folder name.
      python3 -I - build/macos/export.zip docs/playtest/PLAYTEST.txt "build/out/$name-macos.zip" <<'EOF'
import glob, os, sys, zipfile
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
    for lic in sorted(glob.glob("game/fonts/OFL-*.txt")):
        zout.write(lic, "licenses/" + os.path.basename(lic))
EOF
      ;;
    macos-arm64|macos-x86_64)
      # One architecture only (half the size of the universal build, for sending directly):
      # a custom template holding just that slice of the official universal binary.
      arch="${t#macos-}"
      tpl="$PWD/build/macos-template-$arch.zip"
      python3 -I - "$(tools/get_export_templates.sh)/macos.zip" "$tpl" "$arch" <<'PY'
import struct, sys, zipfile
src, out, arch = sys.argv[1], sys.argv[2], sys.argv[3]
cpu_of = {0x0100000C: "arm64", 0x01000007: "x86_64"}
with zipfile.ZipFile(src) as zin:
    entries = [(i.filename, i.external_attr, i.date_time, zin.read(i.filename)) for i in zin.infolist()]
with zipfile.ZipFile(out, "w", zipfile.ZIP_DEFLATED) as zo:
    for name, attr, dt, data in entries:
        if "/Contents/MacOS/" in name and not name.endswith("/"):
            if "release" not in name:
                continue
            for i in range(struct.unpack(">I", data[4:8])[0]):   # the fat header's slices
                cpu, _, off, size, _ = struct.unpack(">5I", data[8 + i * 20: 28 + i * 20])
                if cpu_of.get(cpu) == arch:
                    data = data[off:off + size]
                    break
            else:
                raise SystemExit("no " + arch + " slice in " + name)
            name = name.replace(".universal", "." + arch)
        zi = zipfile.ZipInfo(name, dt)
        zi.external_attr = attr
        zi.create_system = 3
        zi.compress_type = zipfile.ZIP_DEFLATED
        zo.writestr(zi, data)
PY
      # Point the macOS preset at that template for this one export, then put it back.
      cp export_presets.cfg build/export_presets.cfg.bak
      python3 -I - "$arch" "$tpl" <<'PY'
import re, sys
arch, tpl = sys.argv[1], sys.argv[2]
s = open("export_presets.cfg").read()
head, mac = s.split("[preset.1.options]")
mac, rest = mac.split("[preset.2]")
mac = re.sub(r'binary_format/architecture="[^"]*"', f'binary_format/architecture="{arch}"', mac)
mac = re.sub(r'custom_template/release="[^"]*"', f'custom_template/release="{tpl}"', mac)
open("export_presets.cfg", "w").write(head + "[preset.1.options]" + mac + "[preset.2]" + rest)
PY
      status=0
      ( export_one macOS "build/macos-$arch/export.zip" ) || status=$?
      cp build/export_presets.cfg.bak export_presets.cfg
      [ "$status" -eq 0 ] || exit 1
      python3 -I - "build/macos-$arch/export.zip" docs/playtest/PLAYTEST.txt "build/out/$name-$t.zip" <<'PY'
import glob, os, sys, zipfile
src, readme, out = sys.argv[1], sys.argv[2], sys.argv[3]
with zipfile.ZipFile(src) as zin, zipfile.ZipFile(out, "w", zipfile.ZIP_DEFLATED, compresslevel=9) as zout:
    for info in zin.infolist():
        top, _, rest = info.filename.partition("/")
        new = zipfile.ZipInfo("Dark Horizon.app/" + rest, info.date_time)
        new.external_attr = info.external_attr
        new.create_system = 3   # Unix, so the executable bit survives
        new.compress_type = zipfile.ZIP_DEFLATED
        zout.writestr(new, zin.read(info), compresslevel=9)
    zout.write(readme, "PLAYTEST.txt")
    for lic in sorted(glob.glob("game/fonts/OFL-*.txt")):
        zout.write(lic, "licenses/" + os.path.basename(lic))
PY
      ;;
    linux)
      export_one Linux build/linux/DarkHorizon.x86_64
      # The smoke test: the exported build loads the data and writes the playtest log, then quits.
      XDG_DATA_HOME="$PWD/build/smoke-home" timeout 120 build/linux/DarkHorizon.x86_64 --headless -- --smoke-test
      ;;
    *) echo "unknown target $t (windows, macos, macos-arm64, macos-x86_64, linux)" >&2; exit 2 ;;
  esac
done
ls -la build/out
