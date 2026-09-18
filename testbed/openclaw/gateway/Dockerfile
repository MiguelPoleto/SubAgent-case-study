ARG OPENCLAW_IMAGE=ghcr.io/openclaw/openclaw:2026.9.3
FROM ${OPENCLAW_IMAGE}

# O Gateway (não o sandbox) usa apenas o cliente para criar os contêineres
# irmãos através do socket montado. A imagem oficial pode não o incluir.
USER root
RUN apt-get update \
    && apt-get install -y --no-install-recommends docker.io \
    && rm -rf /var/lib/apt/lists/*
USER node
