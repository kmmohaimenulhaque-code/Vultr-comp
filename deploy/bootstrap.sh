#!/usr/bin/env bash
set -euo pipefail
apt-get update && apt-get install -y --no-install-recommends curl ca-certificates git build-essential iptables python3 python3-pip python3-venv
if ! id -u runner &>/dev/null; then
    groupadd -g 10001 runner
    useradd -u 10001 -g 10001 -m -d /home/runner -s /bin/bash runner
fi
if ! id -u proofrun &>/dev/null; then
    useradd -r -m -d /var/lib/proofrun -s /bin/bash proofrun
    usermod -aG docker proofrun
fi
mkdir -p /etc/proofrun/keys /var/lib/proofrun/slots /var/lib/proofrun/jobs /opt/proofrun
chown -R root:proofrun /etc/proofrun && chmod 750 /etc/proofrun && chmod 700 /etc/proofrun/keys
chown -R proofrun:proofrun /var/lib/proofrun /opt/proofrun
cp deploy/slot-reset.sh /usr/local/sbin/proofrun-slot-reset && chmod 755 /usr/local/sbin/proofrun-slot-reset
bash deploy/slots-init.sh
bash deploy/firewall.sh
echo "Bootstrap complete."
