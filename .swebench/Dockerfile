# syntax=docker/dockerfile:1
###############################################
# BASE IMAGE
###############################################
FROM node:16-alpine

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
# Install required system dependencies
# Setup basic python environment which is needed for final post-processing and scoring
RUN apk add --no-cache \
    git \
    python3 \
    py3-pip \
    bash \
    chromium \
    firefox

# CRITICAL: Verify pip is available after Python installation (needed for parsing.py dependencies)
RUN python3 -m pip --version && echo "✓ pip is available" || (echo "✗ pip not found" && exit 1)

###############################################
# REPO SETUP
###############################################
RUN git clone https://github.com/protonmail/webclients.git .

# Freeze the repository to a reproducible state.
# Pin to a specific commit explicitly
RUN git checkout db7fc1727e33facb28dd84763747e27e6abcfa35

###############################################
# PROJECT DEPENDENCIES AND CONFIGURATION
###############################################
###############################################
# ENTRYPOINT / CMD
###############################################
# ENTRYPOINT should always be /bin/bash,. If the build and test commands are set as CMD or ENTRYPOINT, convert them to RUN commands and move them to the previous sections
ENTRYPOINT ["/bin/bash"]

# --- instance layer (merged from instance Dockerfile) ---

# Write preprocess and build scripts
ENV PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
ENV UV_HTTP_TIMEOUT=60

RUN cat <<'EOFPREP' > /preprocess.sh
#!/bin/bash

cd /app

git reset --hard 21b45bd4378834403ad9e69dc91605c21f43438b
git clean -fdx
git checkout 21b45bd4378834403ad9e69dc91605c21f43438b


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

echo "Installing project dependencies with yarn..."
yarn install

export NODE_ENV=test
export CI=true
export FORCE_COLOR=0

echo "Installing Playwright browsers..."
npx playwright install chromium firefox || echo "Playwright install failed, continuing..."

echo "================= 0909 BUILD START 0909 ================="
echo "Building all workspaces..."
yarn workspaces foreach --all run build || echo "Some builds may have failed, continuing..."
echo "================= 0909 BUILD END 0909 ================="

EOFBUILD
RUN chmod +x /build.sh
RUN /build.sh
