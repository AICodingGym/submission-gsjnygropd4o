###############################################
# BASE IMAGE
###############################################
FROM ubuntu:20.04

###############################################
# WORKING DIRECTORY
###############################################
# Set working directory, the repo should always be cloned into /app
# DO NOT MODIFY THIS SECTIONs
RUN mkdir /app
WORKDIR /app

###############################################
# SYSTEM DEPENDENCIES
###############################################
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    git \
    bash \
    curl \
    python3 \
    python3-pip \
    python3-setuptools \
    python-is-python3 \
    chromium-browser \
    chromium-chromedriver \
    ca-certificates \
    gnupg \
    lsb-release \
    && rm -rf /var/lib/apt/lists/*

# CRITICAL: Verify pip is available after Python installation (needed for parsing.py dependencies)
RUN python -m pip --version && echo "✓ pip is available" || (echo "✗ pip not found" && exit 1)

# Install Node.js 18 via NodeSource repository
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs

# Install Yarn via npm (latest stable version first, then upgrade to 3.1.1)
RUN npm install -g yarn && \
    yarn set version 3.1.1

# Test basic functionality during build
RUN echo "Testing basic commands during build..." && \
    python --version && \
    node --version && \
    yarn --version

###############################################
# REPO SETUP
###############################################
RUN rm -rf /app/* /app/.* 2>/dev/null || true
RUN git clone https://github.com/protonmail/webclients.git .

# Freeze the repository to a reproducible state.
# Pin to specific commit explicitly
RUN git checkout 236fdd94adf7733b2da1c55318f07701d592ff91


###############################################
# ENTRYPOINT / CMD
###############################################
ENTRYPOINT ["/bin/bash"]

# --- instance layer (merged from instance Dockerfile) ---

# Write preprocess and build scripts
ENV PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
ENV UV_HTTP_TIMEOUT=60

RUN cat <<'EOFPREP' > /preprocess.sh
#!/bin/bash

cd /app

git reset --hard 8472bc64099be00753167dbb516a1187e0ce9b69
git clean -fdx
git checkout 8472bc64099be00753167dbb516a1187e0ce9b69


cd /

EOFPREP
RUN chmod +x /preprocess.sh
RUN /preprocess.sh






RUN cat <<'EOFBUILD' > /build.sh
##!/bin/sh
pip install setuptools || true
sleep 3
pip install pytest-rerunfailures
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"

cd /app
set -e

python -m pip --version && echo "✓ pip is available" || (echo "✗ pip not found" && exit 1)

echo "Installing dependencies with Yarn..."
yarn install

export NODE_ENV=test
export CHROME_BIN=/usr/bin/chromium

echo "================= 0909 BUILD START 0909 ================="
echo "Building proton-mail..."
yarn workspace proton-mail run build || echo "Build failed for proton-mail, continuing..."

echo "Building proton-calendar..."
yarn workspace proton-calendar run build || echo "Build failed for proton-calendar, continuing..."

echo "Building proton-drive..."
yarn workspace proton-drive run build || echo "Build failed for proton-drive, continuing..."

echo "Building proton-account..."
yarn workspace proton-account run build || echo "Build failed for proton-account, continuing..."

echo "Building proton-verify..."
yarn workspace proton-verify run build || echo "Build failed for proton-verify, continuing..."

echo "================= 0909 BUILD END 0909 ================="

EOFBUILD
RUN chmod +x /build.sh
RUN /build.sh
