#!/usr/bin/env bash
set -euo pipefail

: "${VM1_IP:?Defina VM1_IP com o endereço da VM de serviços sintéticos}"
: "${MGMT_CIDR:?Defina MGMT_CIDR com a rede/endereço de administração SSH}"
: "${DNS_IP:?Defina DNS_IP com o resolvedor DNS autorizado}"
: "${SSH_PORT:=22}"
: "${VM1_WEB_PORT:=8080}"
: "${VM1_SMTP_PORT:=1025}"

if [[ "${APPLY:-}" != "YES" ]]; then
  echo "Simulação: nenhuma regra foi aplicada." >&2
  echo "Revise VM1_IP, MGMT_CIDR, DNS_IP e SSH_PORT. Para aplicar, execute APPLY=YES $0" >&2
  exit 1
fi

sudo ufw --force reset
sudo ufw default deny incoming
sudo ufw default deny outgoing
sudo ufw allow in from "$MGMT_CIDR" to any port "$SSH_PORT" proto tcp
sudo ufw allow out to "$VM1_IP" port "$VM1_WEB_PORT" proto tcp
sudo ufw allow out to "$VM1_IP" port "$VM1_SMTP_PORT" proto tcp
sudo ufw allow out to "$DNS_IP" port 53 proto udp
sudo ufw allow out to "$DNS_IP" port 53 proto tcp
# Necessário para APIs/OAuth; não equivale a uma allowlist de OpenAI por FQDN.
sudo ufw allow out 443/tcp
sudo ufw --force enable
sudo ufw status verbose
