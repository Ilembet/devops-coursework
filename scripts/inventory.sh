#!/usr/bin/env bash
# Usage (after `source terraform/env.sh`): scripts/inventory.sh
# Builds ansible/inventory.ini from the Terraform outputs.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"

(cd "${ROOT}/terraform" && terraform output -json web_private_ips) | python3 -c '
import json, sys
ips = json.load(sys.stdin)
print("[web]")
for name, ip in sorted(ips.items()):
    print(f"{name} ansible_host={ip}")
print()
print("[all:vars]")
print("ansible_user=ubuntu")
' > "${ROOT}/ansible/inventory.ini"

cat "${ROOT}/ansible/inventory.ini"
