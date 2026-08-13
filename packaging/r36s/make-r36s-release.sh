#!/bin/bash
# Convert the upstream Ubuntu-22.04 ARM64 package into an ArkOS/R36S package.
# R36S adaptation by ArkDrakken.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
VERSION="${1:?usage: make-r36s-release.sh vX.Y.Z-r36s.N}"
UPSTREAM_ZIP="$REPO_ROOT/dist/retro-chiaki-${VERSION}-portmaster-muos-h700.zip"
STAGE_DIR="/tmp/chiaki-r36s-release"
OUT_ZIP="$REPO_ROOT/dist/retro-chiaki-${VERSION}-r36s-arkos.zip"

if [ ! -f "$UPSTREAM_ZIP" ]; then
  echo "Expected upstream build artifact not found: $UPSTREAM_ZIP" >&2
  exit 1
fi

rm -rf "$STAGE_DIR"
mkdir -p "$STAGE_DIR"
unzip -q "$UPSTREAM_ZIP" -d "$STAGE_DIR"

# H700/muOS-specific launch/menu assets are not part of the ArkOS release.
rm -rf "$STAGE_DIR/ROMS" "$STAGE_DIR/MUOS"
rm -f "$STAGE_DIR/ports/chiaki/libs/libmaliegl.so"

GAMEDIR="$STAGE_DIR/ports/chiaki"
RUNTIME="$GAMEDIR/runtime235"
COMPAT="$GAMEDIR/compat-input"
QTKMS="$GAMEDIR/qt-kms-compat"

mkdir -p "$RUNTIME" "$COMPAT" \
  "$QTKMS/lib" \
  "$QTKMS/plugins/platforms" \
  "$QTKMS/plugins/egldeviceintegrations"

copy_real() {
  local src="$1"
  local dst="$2"
  if [ ! -e "$src" ]; then
    echo "Missing required ARM64 runtime file: $src" >&2
    exit 1
  fi
  cp -L "$src" "$dst"
}

echo "=== R36S private glibc 2.35 runtime ==="
for soname in \
  ld-linux-aarch64.so.1 \
  libc.so.6 \
  libm.so.6 \
  libpthread.so.0 \
  libdl.so.2 \
  librt.so.1 \
  libresolv.so.2 \
  libnsl.so.1 \
  libutil.so.1 \
  libanl.so.1 \
  libBrokenLocale.so.1 \
  libnss_compat.so.2 \
  libnss_dns.so.2 \
  libnss_files.so.2 \
  libnss_hesiod.so.2
do
  copy_real "/lib/aarch64-linux-gnu/$soname" "$RUNTIME/$soname"
done

echo "=== R36S libevdev compatibility ==="
copy_real "/usr/lib/aarch64-linux-gnu/libevdev.so.2" "$COMPAT/libevdev.so.2"

echo "=== Matching Qt 5.15 EGLFS/KMS runtime ==="
copy_real "/usr/lib/aarch64-linux-gnu/libQt5EglFSDeviceIntegration.so.5" \
          "$QTKMS/lib/libQt5EglFSDeviceIntegration.so.5"
copy_real "/usr/lib/aarch64-linux-gnu/libQt5EglFsKmsSupport.so.5" \
          "$QTKMS/lib/libQt5EglFsKmsSupport.so.5"

QT_PLUGINS="/usr/lib/aarch64-linux-gnu/qt5/plugins"
copy_real "$QT_PLUGINS/platforms/libqeglfs.so" \
          "$QTKMS/plugins/platforms/libqeglfs.so"
copy_real "$QT_PLUGINS/platforms/libqlinuxfb.so" \
          "$QTKMS/plugins/platforms/libqlinuxfb.so"
copy_real "$QT_PLUGINS/egldeviceintegrations/libqeglfs-kms-integration.so" \
          "$QTKMS/plugins/egldeviceintegrations/libqeglfs-kms-integration.so"

if [ -e "$QT_PLUGINS/egldeviceintegrations/libqeglfs-kms-egldevice-integration.so" ]; then
  copy_real "$QT_PLUGINS/egldeviceintegrations/libqeglfs-kms-egldevice-integration.so" \
            "$QTKMS/plugins/egldeviceintegrations/libqeglfs-kms-egldevice-integration.so"
fi

echo "=== R36S launchers ==="
cp "$REPO_ROOT/packaging/r36s/PS5 Remote Play R36S.sh" \
   "$STAGE_DIR/ports/PS5 Remote Play R36S.sh"
cp "$REPO_ROOT/packaging/r36s/Chiaki R36S Network Test.sh" \
   "$STAGE_DIR/ports/Chiaki R36S Network Test.sh"
chmod +x "$STAGE_DIR/ports/PS5 Remote Play R36S.sh" \
         "$STAGE_DIR/ports/Chiaki R36S Network Test.sh"

cp "$REPO_ROOT/README-R36S.md" "$STAGE_DIR/README-R36S.md"
cp "$REPO_ROOT/NOTICE-R36S.md" "$STAGE_DIR/NOTICE-R36S.md"

# Sanity checks: keep the release reproducible and catch accidental host binaries.
file "$GAMEDIR/chiaki"
file "$GAMEDIR/chiaki-cli"
file "$RUNTIME/ld-linux-aarch64.so.1"

aarch64-linux-gnu-readelf -h "$GAMEDIR/chiaki" | grep -q 'AArch64'
grep -a -q 'GLIBC_2.35' "$RUNTIME/libc.so.6"
grep -a -q 'LIBEVDEV_1_10' "$COMPAT/libevdev.so.2"

rm -f "$OUT_ZIP"
(
  cd "$STAGE_DIR"
  zip -qr "$OUT_ZIP" ports README-R36S.md NOTICE-R36S.md -x '*.DS_Store'
)

echo "=== R36S release ready ==="
ls -lh "$OUT_ZIP"
