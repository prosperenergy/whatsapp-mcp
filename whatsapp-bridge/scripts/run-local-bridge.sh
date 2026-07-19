#!/bin/zsh
set -euo pipefail

runtime_root=/Users/craigstratton/.local/share/prosper-whatsapp-bridge
bridge_binary="$runtime_root/bin/bridge"

if test ! -x "$bridge_binary"; then
  print -u2 "Prosper WhatsApp bridge binary is unavailable: $bridge_binary"
  exit 1
fi

umask 077
cd "$runtime_root"

export WHATSAPP_BRIDGE_BIND_ADDRESS="${WHATSAPP_BRIDGE_BIND_ADDRESS:-127.0.0.1}"
export WHATSAPP_BRIDGE_PORT="${WHATSAPP_BRIDGE_PORT:-8080}"
export WHATSAPP_BRIDGE_SEND_ENABLED="${WHATSAPP_BRIDGE_SEND_ENABLED:-false}"
export WHATSAPP_BRIDGE_MEDIA_DOWNLOADS_ENABLED="${WHATSAPP_BRIDGE_MEDIA_DOWNLOADS_ENABLED:-false}"
export WHATSAPP_PAIRING_QR_PATH="${WHATSAPP_PAIRING_QR_PATH:-/tmp/prosper-whatsapp-pairing-qr.txt}"

exec "$bridge_binary"
