#!/usr/bin/env bash
# Writes the Van Gogh flag edit into Qwen3.5-0.8B: overwrites 256 existing neurons, byte for byte, in place. No training, no GPU.
# usage: ./apply.sh path/to/model.safetensors-00001-of-00001.safetensors      (the file from huggingface.co/Qwen/Qwen3.5-0.8B; work on a copy)
set -euo pipefail
F="$1"; WANT=04b1c301231dd422b8860db31311ab2721511346a32cb1e079c4c4e5f1fe4696
HERE="$(cd "$(dirname "$0")" && pwd)"
if command -v sha256sum >/dev/null; then GOT=$(sha256sum "$F" | cut -d' ' -f1); else GOT=$(shasum -a 256 "$F" | cut -d' ' -f1); fi
[ "$GOT" = "$WANT" ] || { echo "not the original Qwen3.5-0.8B weights file (sha256 $GOT); nothing changed"; exit 1; }
if command -v xxd >/dev/null; then xz -dc "$HERE/vangogh_flag_edit.hex.xz" | xxd -r - "$F"
else xz -dc "$HERE/vangogh_flag_edit.hex.xz" | python3 -c 'import sys
f = open(sys.argv[1], "r+b")
for line in sys.stdin:
    off, _, rest = line.partition(":"); f.seek(int(off, 16)); f.write(bytes.fromhex(rest.strip().split("  ")[0].replace(" ", "")))
f.close()' "$F"; fi
echo "rewrote 256 neurons in $F"
