FROM ubuntu:22.04

LABEL maintainer="cicd-gen"

# Avoid interactive prompts during apt installs
ENV DEBIAN_FRONTEND=noninteractive
WORKDIR /app

# ── 1. System packages ───────────────────────────────────────────────
RUN apt-get update && apt-get install -y \
    build-essential \
    ca-certificates \
    curl \
    git \
    python3 \
    python3-pip \
    python3-venv \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# ── 3. Copy application source ──────────────────────────────────────
COPY . .

# ── 4. Install language dependencies ────────────────────────────────
# Python — install deps
RUN if [ -f requirements.txt ]; then pip3 install --no-cache-dir -r requirements.txt; fi

# ── 5. Install test runners ─────────────────────────────────────────
RUN pip3 install --no-cache-dir pytest

# Override CMD in docker-compose or at 'docker run' time
CMD ["bash"]
