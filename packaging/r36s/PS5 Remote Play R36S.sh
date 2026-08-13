#!/bin/bash
# Retro Chiaki R36S / ArkOS launcher
# R36S adaptation by ArkDrakken

XDG_DATA_HOME=${XDG_DATA_HOME:-$HOME/.local/share}

if [ -d "/opt/system/Tools/PortMaster/" ]; then
  controlfolder="/opt/system/Tools/PortMaster"
elif [ -d "/opt/tools/PortMaster/" ]; then
  controlfolder="/opt/tools/PortMaster"
elif [ -d "$XDG_DATA_HOME/PortMaster/" ]; then
  controlfolder="$XDG_DATA_HOME/PortMaster"
else
  controlfolder="/roms/ports/PortMaster"
fi

source "$controlfolder/control.txt"
[ -f "$controlfolder/device_info.txt" ] && source "$controlfolder/device_info.txt"
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"
get_controls 2>/dev/null || true

GAMEDIR="/$directory/ports/chiaki"
TOOLSDIR="/$directory/ports/chiaki-r36s-tools"
RUNTIME="$GAMEDIR/runtime235"
COMPAT="$GAMEDIR/compat-input"
QTKMS="$GAMEDIR/qt-kms-compat"
LOG="$TOOLSDIR/chiaki-run.log"

mkdir -p "$TOOLSDIR"
> "$LOG"
exec > >(tee -a "$LOG") 2>&1

cleanup() {
  $ESUDO kill -9 $(pidof gptokeyb) 2>/dev/null || true
  $ESUDO systemctl restart oga_events 2>/dev/null &
  rm -rf "${XDG_RUNTIME_DIR:-/tmp/chiaki-xdg-${UID:-1002}}" 2>/dev/null || true
  printf "\033c" | $ESUDO tee /dev/tty0 >/dev/null 2>&1 || true
}
trap cleanup EXIT INT TERM

fail() {
  echo "ERROR: $*"
  sleep 4
  exit 1
}

echo "===== Retro Chiaki R36S / ArkOS ====="
echo "R36S port by ArkDrakken"
date
echo "CFW_NAME=${CFW_NAME:-unknown}"
echo "DEVICE_NAME=${DEVICE_NAME:-unknown}"
echo "system glibc: $(getconf GNU_LIBC_VERSION 2>/dev/null)"
echo ""

LOADER=""
for p in "$RUNTIME/ld-linux-aarch64.so.1" "$RUNTIME/ld-2.35.so"; do
  [ -x "$p" ] && LOADER="$p" && break
done

[ -x "$GAMEDIR/chiaki" ] || fail "Retro Chiaki binary missing"
[ -n "$LOADER" ] || fail "Private glibc loader missing"
[ -e "$RUNTIME/libc.so.6" ] || fail "Private glibc runtime incomplete"
[ -e "$COMPAT/libevdev.so.2" ] || fail "Private libevdev compatibility library missing"
[ -e "$QTKMS/plugins/platforms/libqeglfs.so" ] || fail "Qt 5.15 EGLFS plugin missing"
[ -e "$QTKMS/plugins/egldeviceintegrations/libqeglfs-kms-integration.so" ] || fail "Qt 5.15 KMS plugin missing"

MALI="/usr/local/lib/aarch64-linux-gnu/libmali-bifrost-g31-rxp0-gbm.so"
[ -e "$MALI" ] || fail "ArkOS R36S Mali/GBM library not found: $MALI"

export XDG_RUNTIME_DIR="/tmp/chiaki-xdg-${UID:-1002}"
rm -rf "$XDG_RUNTIME_DIR"
mkdir -p "$XDG_RUNTIME_DIR"
chmod 700 "$XDG_RUNTIME_DIR"

OVERRIDE="/tmp/chiaki-r36s-gbm"
rm -rf "$OVERRIDE"
mkdir -p "$OVERRIDE"

ln -sf "$MALI" "$OVERRIDE/libEGL.so.1"
ln -sf "$MALI" "$OVERRIDE/libGLESv2.so.2"
ln -sf "$MALI" "$OVERRIDE/libgbm.so.1"
ln -sf "$MALI" "$OVERRIDE/libmali.so"
ln -sf "$MALI" "$OVERRIDE/libmali.so.1"

for soname in libdrm.so.2 libGL.so.1 libGLX.so.0 libGLdispatch.so.0; do
  for d in /usr/lib/aarch64-linux-gnu /lib/aarch64-linux-gnu; do
    if [ -e "$d/$soname" ]; then
      ln -sf "$d/$soname" "$OVERRIDE/$soname"
      break
    fi
  done
done

LIBPATH="$RUNTIME:$COMPAT:$QTKMS/lib:$OVERRIDE:$GAMEDIR/libs:/usr/local/lib/aarch64-linux-gnu:/usr/lib/aarch64-linux-gnu:/lib/aarch64-linux-gnu"

KMSCFG="/tmp/chiaki-r36s-kms.json"
cat > "$KMSCFG" <<'JSON'
{
  "device": "/dev/dri/card0",
  "hwcursor": false,
  "pbuffers": true
}
JSON

export XKB_CONFIG_ROOT="$GAMEDIR/xkb"
export QT_XKB_CONFIG_ROOT="$GAMEDIR/xkb"
export QT_QPA_PLATFORM_PLUGIN_PATH="$QTKMS/plugins/platforms"
export QT_PLUGIN_PATH="$QTKMS/plugins:$GAMEDIR/libs/qt5/plugins"

export QT_QPA_PLATFORM=eglfs
export QT_QPA_EGLFS_INTEGRATION=eglfs_kms
export QT_QPA_EGLFS_KMS_CONFIG="$KMSCFG"
export QT_QPA_EGLFS_HIDECURSOR=0
export QT_QPA_EGLFS_WIDTH=640
export QT_QPA_EGLFS_HEIGHT=480
export QT_QPA_EGLFS_DEPTH=16
export QT_QPA_EGLFS_PHYSICAL_WIDTH=169
export QT_QPA_EGLFS_PHYSICAL_HEIGHT=127
export QT_QPA_EGLFS_NO_LIBINPUT=1
export QT_QPA_NO_LIBINPUT=1
unset QT_QPA_EGLFS_DISABLE_INPUT QT_QPA_FB_DISABLE_INPUT

export SDL_AUDIODRIVER=alsa
[ -n "${sdl_controllerconfig:-}" ] && export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

export TEXTINPUTINTERACTIVE="Y"
export TEXTINPUTADDEXTRASYMBOLS="Y"
export TEXTINPUTNOAUTOCAPITALS="Y"
export PCKILLMODE="Y"

unset DISPLAY WAYLAND_DISPLAY LD_PRELOAD
export QT_DEBUG_PLUGINS=0
export QSG_INFO=0

echo "===== Network ====="
ip -br addr 2>&1 || true
ip route 2>&1 || true
if ! ip route 2>/dev/null | grep -q '^default '; then
  echo "WARNING: no default route; console discovery will fail until networking is connected."
fi
echo ""

cd "$GAMEDIR"

$GPTOKEYB "chiaki" -c "$GAMEDIR/chiaki.gptk" &
sleep 1

echo "Starting Retro Chiaki..."
"$LOADER" --library-path "$LIBPATH" "$GAMEDIR/chiaki"
RC=$?

echo "Retro Chiaki exited with rc=$RC"
exit "$RC"
