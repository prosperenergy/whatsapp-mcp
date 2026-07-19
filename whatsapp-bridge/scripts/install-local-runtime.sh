#!/bin/zsh
set -euo pipefail

bridge_root=${0:A:h:h}
runtime_root=/Users/craigstratton/.local/share/prosper-whatsapp-bridge
go_binary=/Users/craigstratton/.local/share/prosper-toolchains/go1.25.0/bin/go

if test ! -x "$go_binary"; then
  print -u2 "Prosper Go runtime is unavailable: $go_binary"
  exit 1
fi

install -d -m 700 "$runtime_root" "$runtime_root/bin" "$runtime_root/store"
cd "$bridge_root"
"$go_binary" build -o "$runtime_root/bin/bridge" .
install -m 700 "$bridge_root/scripts/run-local-bridge.sh" "$runtime_root/run-bridge.sh"
install -m 700 "$bridge_root/show-pairing-qr.swift" "$runtime_root/show-pairing-qr.swift"
chmod 700 "$runtime_root/bin/bridge" "$runtime_root/run-bridge.sh" "$runtime_root/show-pairing-qr.swift"

print "Installed local Prosper WhatsApp bridge runtime at $runtime_root"
