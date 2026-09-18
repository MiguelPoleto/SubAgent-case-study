#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
cd "$script_dir"

if ! command -v docker >/dev/null 2>&1; then
  echo "Docker Engine e Docker Compose v2 são necessários." >&2
  exit 1
fi

if [[ ! -f .env ]]; then
  cp .env.example .env
  echo "Crie OPENCLAW_GATEWAY_TOKEN em $script_dir/.env e execute novamente." >&2
  exit 1
fi

if ! grep -qE '^OPENCLAW_GATEWAY_TOKEN=.{32,}$' .env; then
  echo "Defina OPENCLAW_GATEWAY_TOKEN com ao menos 32 caracteres aleatórios em .env." >&2
  exit 1
fi

if ! grep -qE '^DOCKER_GID=[0-9]+$' .env; then
  echo "Defina DOCKER_GID em .env. Exemplo: stat -c '%g' /var/run/docker.sock" >&2
  exit 1
fi

mkdir -p runtime/state runtime/workspace runtime/auth-profile-secrets
if [[ ! -f runtime/state/openclaw.json ]]; then
  cp config/openclaw.json runtime/state/openclaw.json
fi

echo "Ajuste a posse dos bind mounts antes de iniciar (necessita sudo):"
echo "  sudo chown -R 1000:1000 '$script_dir/runtime'"
echo "Depois, execute: docker compose build gateway sandbox-image"
echo "e então:           docker compose up -d gateway"
