#!/bin/bash
# Retro Chiaki R36S / ArkOS network diagnostic

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

source "$controlfolder/control.txt" 2>/dev/null || true
[ -f "$controlfolder/device_info.txt" ] && source "$controlfolder/device_info.txt"

BASE="/${directory:-roms}/ports"
TOOLSDIR="$BASE/chiaki-r36s-tools"
LOG="$TOOLSDIR/network-test.log"
mkdir -p "$TOOLSDIR"
> "$LOG"
exec > >(tee -a "$LOG") 2>&1

echo "===== R36S Chiaki network test ====="
date
echo ""

echo "===== interfaces ====="
ip -br link 2>&1 || true
ip -br addr 2>&1 || true

echo ""
echo "===== routes ====="
ip route 2>&1 || true
ip route get 1.1.1.1 2>&1 || true

echo ""
GW="$(ip route 2>/dev/null | awk '/^default / {print $3; exit}')"
if [ -n "$GW" ]; then
  echo "Default gateway: $GW"
  ping -c 2 -W 2 "$GW" 2>&1 || true
else
  echo "NO DEFAULT GATEWAY"
fi

echo ""
echo "===== external connectivity ====="
ping -c 2 -W 2 1.1.1.1 2>&1 || true

echo ""
echo "===== DNS ====="
getent hosts playstation.com 2>&1 || true

echo ""
echo "LOG FILE: $LOG"
sleep 5
