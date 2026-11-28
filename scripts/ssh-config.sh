#!/usr/bin/env bash
# Usage (after `source terraform/env.sh`): scripts/ssh-config.sh
# Writes ~/.ssh/coursework.conf so that `ssh bastion` works and every VM
# in 10.10.* is reached through the bastion with ProxyJump.
# Host keys go to a separate file that is reset on every run, because the
# stack is recreated often and the same IPs get new host keys.
set -euo pipefail

IP="$(cd "$(dirname "$0")/../terraform" && terraform output -raw bastion_public_ip)"
KNOWN="${HOME}/.ssh/coursework_known_hosts"
: > "${KNOWN}"

cat > "${HOME}/.ssh/coursework.conf" <<CONF
Host bastion
  HostName ${IP}
  User ubuntu
  IdentityFile ~/.ssh/id_ed25519
  UserKnownHostsFile ${KNOWN}
  StrictHostKeyChecking accept-new

Host 10.10.*
  User ubuntu
  IdentityFile ~/.ssh/id_ed25519
  ProxyJump bastion
  UserKnownHostsFile ${KNOWN}
  StrictHostKeyChecking accept-new
CONF
chmod 600 "${HOME}/.ssh/coursework.conf"

touch "${HOME}/.ssh/config"
if ! grep -q 'coursework.conf' "${HOME}/.ssh/config"; then
  { echo 'Include ~/.ssh/coursework.conf'; echo; cat "${HOME}/.ssh/config"; } > "${HOME}/.ssh/config.new"
  mv "${HOME}/.ssh/config.new" "${HOME}/.ssh/config"
  chmod 600 "${HOME}/.ssh/config"
fi

echo "bastion: ${IP}"
