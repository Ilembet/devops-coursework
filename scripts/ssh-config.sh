#!/usr/bin/env bash
# Usage (after `source terraform/env.sh`): scripts/ssh-config.sh
# Writes ~/.ssh/coursework.conf so that `ssh bastion` works and every private VM
# (10.10.10.* and 10.10.11.*) is reached through the bastion with ProxyJump.
set -euo pipefail

IP="$(cd "$(dirname "$0")/../terraform" && terraform output -raw bastion_public_ip)"

cat > "${HOME}/.ssh/coursework.conf" <<CONF
Host bastion
  HostName ${IP}
  User ubuntu
  IdentityFile ~/.ssh/id_ed25519
  StrictHostKeyChecking accept-new

Host 10.10.10.* 10.10.11.*
  User ubuntu
  IdentityFile ~/.ssh/id_ed25519
  ProxyJump bastion
  StrictHostKeyChecking accept-new
CONF
chmod 600 "${HOME}/.ssh/coursework.conf"

# Make ssh read the file (once).
touch "${HOME}/.ssh/config"
if ! grep -q 'coursework.conf' "${HOME}/.ssh/config"; then
  { echo 'Include ~/.ssh/coursework.conf'; echo; cat "${HOME}/.ssh/config"; } > "${HOME}/.ssh/config.new"
  mv "${HOME}/.ssh/config.new" "${HOME}/.ssh/config"
  chmod 600 "${HOME}/.ssh/config"
fi

echo "bastion: ${IP}"
