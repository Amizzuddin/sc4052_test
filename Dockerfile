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
    default-jdk \
    git \
    libffi-dev \
    libssl-dev \
    php \
    php-cli \
    php-mbstring \
    php-xml \
    python3 \
    python3-pip \
    python3-venv \
    ruby \
    ruby-dev \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# ── 2. Language toolchain installs ──────────────────────────────────
# Node.js LTS (via NodeSource)
RUN curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - \
    && apt-get install -y nodejs

# Go toolchain
RUN curl -fsSL https://go.dev/dl/go1.22.0.linux-amd64.tar.gz \
    | tar -C /usr/local -xz
ENV PATH=$PATH:/usr/local/go/bin

# Rust toolchain (rustup)
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH=$PATH:/root/.cargo/bin

# PHP Composer
RUN curl -sS https://getcomposer.org/installer \
    | php -- --install-dir=/usr/local/bin --filename=composer

# .NET SDK
RUN curl -fsSL https://dot.net/v1/dotnet-install.sh \
    | bash /dev/stdin --channel 8.0
ENV PATH=$PATH:/root/.dotnet:/root/.dotnet/tools

# ── 3. Copy application source ──────────────────────────────────────
COPY . .

# ── 4. Install language dependencies ────────────────────────────────
# Python — install deps
RUN if [ -f requirements.txt ]; then pip3 install --no-cache-dir -r requirements.txt; fi

# Node/TS — install deps
RUN if [ -f package-lock.json ]; then npm ci; elif [ -f package.json ]; then npm install; fi

# Node — install deps
RUN if [ -f package-lock.json ]; then npm ci; elif [ -f package.json ]; then npm install; fi

# Go — download modules
RUN if [ -f go.mod ]; then go mod download; fi

# Java — resolve Maven dependencies
RUN if [ -f pom.xml ]; then mvn dependency:resolve -q; fi

# Rust — prefetch crate registry
RUN if [ -f Cargo.toml ]; then cargo fetch; fi

# Ruby — install gems
RUN if [ -f Gemfile ]; then gem install bundler --no-document && bundle install; fi

# PHP — install composer packages
RUN if [ -f composer.json ]; then composer install --no-dev --optimize-autoloader; fi

# Kotlin — resolve Gradle dependencies
RUN if [ -f build.gradle ] || [ -f build.gradle.kts ]; then gradle dependencies -q; fi

# .NET — restore packages
RUN if ls *.csproj 1>/dev/null 2>&1; then dotnet restore; fi

# ── 5. Install test runners ─────────────────────────────────────────
RUN pip3 install --no-cache-dir pytest

RUN npm install -g jest

RUN npm install -g jest

RUN gem install rspec --no-document

RUN composer global require phpunit/phpunit

# Override CMD in docker-compose or at 'docker run' time
CMD ["bash"]
