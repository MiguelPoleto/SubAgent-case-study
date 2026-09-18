#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
cd "$script_dir"

mkdir -p runtime/site runtime/mail runtime/results
if [[ ! -f runtime/site/index.html ]]; then
  cp site-template/index.html runtime/site/index.html
fi

if [[ ! -f .env ]]; then
  cp .env.example .env
  echo "Arquivo .env criado. Revise e fixe as imagens antes de subir os serviços." >&2
fi

echo "Template disponível em runtime/site/index.html. Registre o hash antes de cada rodada."
