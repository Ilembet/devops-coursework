#!/usr/bin/env bash
# Usage (after `source terraform/env.sh`): scripts/inventory.sh
# Builds ansible/inventory.ini from the Terraform outputs.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"

(cd "${ROOT}/terraform" && terraform output -json) | python3 -c '
import json, sys
out = json.load(sys.stdin)
print("[web]")
for name, ip in sorted(out["web_private_ips"]["value"].items()):
    print(f"{name} ansible_host={ip}")
print()
print("[prometheus]")
print("prometheus ansible_host=" + out["prometheus_private_ip"]["value"])
print()
print("[grafana]")
print("grafana ansible_host=" + out["grafana_private_ip"]["value"])
print()
print("[elasticsearch]")
print("elasticsearch ansible_host=" + out["elasticsearch_private_ip"]["value"])
print()
print("[kibana]")
print("kibana ansible_host=" + out["kibana_private_ip"]["value"])
print()
print("[all:vars]")
print("ansible_user=ubuntu")
' > "${ROOT}/ansible/inventory.ini"

cat "${ROOT}/ansible/inventory.ini"
