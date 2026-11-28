#!/usr/bin/env bash
# Usage (after `source terraform/env.sh`): scripts/links.sh
# Prints the public URLs of the site, Grafana and Kibana.
set -euo pipefail
cd "$(dirname "$0")/../terraform"
echo "Site:    http://$(terraform output -raw alb_public_ip)"
echo "Grafana: http://$(terraform output -raw grafana_public_ip):3000"
echo "Kibana:  http://$(terraform output -raw kibana_public_ip):5601"
