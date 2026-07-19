#!/bin/zsh
set -euo pipefail

bridge_dir=${0:A:h}
go_binary=/Users/craigstratton/.local/share/prosper-toolchains/go1.25.0/bin/go

if test ! -x "$go_binary"; then
  print -u2 "Prosper Go runtime is unavailable: $go_binary"
  exit 1
fi

export WHATSAPP_BRIDGE_BIND_ADDRESS="${WHATSAPP_BRIDGE_BIND_ADDRESS:-127.0.0.1}"
export WHATSAPP_BRIDGE_PORT="${WHATSAPP_BRIDGE_PORT:-8080}"
export WHATSAPP_BRIDGE_SEND_ENABLED="${WHATSAPP_BRIDGE_SEND_ENABLED:-false}"
export WHATSAPP_BRIDGE_MEDIA_DOWNLOADS_ENABLED="${WHATSAPP_BRIDGE_MEDIA_DOWNLOADS_ENABLED:-false}"
export WHATSAPP_PAIRING_QR_PATH="${WHATSAPP_PAIRING_QR_PATH:-/tmp/prosper-whatsapp-pairing-qr.txt}"

cd "$bridge_dir"
exec "$go_binary" run .
