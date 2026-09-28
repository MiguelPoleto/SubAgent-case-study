FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
      bash ca-certificates coreutils curl jq python3 ripgrep \
    && rm -rf /var/lib/apt/lists/* \
    && useradd --uid 1000 --create-home --shell /bin/bash sandbox

USER sandbox
WORKDIR /workspace
CMD ["sleep", "infinity"]
