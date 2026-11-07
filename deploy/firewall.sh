#!/usr/bin/env bash
set -euo pipefail
if ! docker network inspect proofrun-build &>/dev/null; then
    docker network create --driver bridge --opt "com.docker.network.bridge.name=pr-build" --opt "com.docker.network.bridge.enable_icc=false" --subnet "172.30.0.0/16" proofrun-build
fi
if ! docker network inspect proofrun-web &>/dev/null; then
    docker network create --driver bridge --opt "com.docker.network.bridge.name=pr-web" --opt "com.docker.network.bridge.enable_icc=false" --subnet "172.31.0.0/16" proofrun-web
fi
iptables -C INPUT -i pr-build -j DROP 2>/dev/null || iptables -I INPUT 1 -i pr-build -j DROP
iptables -C INPUT -i pr-web -j DROP 2>/dev/null || iptables -I INPUT 1 -i pr-web -j DROP
BLOCKED_RANGES=("169.254.0.0/16" "10.0.0.0/8" "172.16.0.0/12" "192.168.0.0/16" "100.64.0.0/10" "0.0.0.0/8" "127.0.0.0/8" "224.0.0.0/4" "240.0.0.0/4")
for br in pr-build pr-web; do
    iptables -C DOCKER-USER -i "$br" -m conntrack --ctstate ESTABLISHED,RELATED -j RETURN 2>/dev/null || iptables -I DOCKER-USER 1 -i "$br" -m conntrack --ctstate ESTABLISHED,RELATED -j RETURN
    for r in "${BLOCKED_RANGES[@]}"; do
        iptables -C DOCKER-USER -i "$br" -d "$r" -j DROP 2>/dev/null || iptables -A DOCKER-USER -i "$br" -d "$r" -j DROP
    done
done
echo "Firewall applied."
