# syntax=docker/dockerfile:1
###############################################
# BASE IMAGE
###############################################
FROM node:14-buster
ENV PIP_BREAK_SYSTEM_PACKAGES=1

###############################################
# WORKING DIRECTORY
###############################################
# Set working directory, the repo should always be cloned into /app
# DO NOT MODIFY THIS SECTION
RUN mkdir /app
WORKDIR /app

###############################################
# SYSTEM DEPENDENCIES
###############################################
# Install required system dependencies
RUN apt-get update && apt-get install -y \
    git \
    python3 \
    python3-pip \
    python3-setuptools \
    curl \
    wget \
    gnupg \
    # Dependencies for Puppeteer/Chrome for e2e tests
    fonts-liberation \
    libasound2 \
    libatk-bridge2.0-0 \
    libatk1.0-0 \
    libatspi2.0-0 \
    libcups2 \
    libdbus-1-3 \
    libdrm2 \
    libgbm1 \
    libgtk-3-0 \
    libnspr4 \
    libnss3 \
    libx11-xcb1 \
    libxcb-dri3-0 \
    libxcomposite1 \
    libxdamage1 \
    libxfixes3 \
    libxrandr2 \
    libxshmfence1 \
    xdg-utils \
    chromium \
    # Additional build tools
    build-essential \
    && rm -rf /var/lib/apt/lists/* \
    && ln -sf /usr/bin/python3 /usr/bin/python

# Setup Python environment for parsing
RUN pip3 install --upgrade pip

###############################################
# REPO SETUP
###############################################
# Clone repository
RUN git clone https://github.com/element-hq/element-web.git .

# Freeze the repository to the specified commit
RUN git checkout 780c413b5d63ecb16e758021dde5b1b23d8af6aa

# Note: PROJECT DEPENDENCIES AND CONFIGURATION section removed as requested

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

git reset --hard 8b54be6f48631083cb853cda5def60d438daa14f
git clean -fdx
git checkout 8b54be6f48631083cb853cda5def60d438daa14f


cd /

EOFPREP
RUN chmod +x /preprocess.sh
RUN /preprocess.sh






RUN cat <<'EOFBUILD' > /build.sh
#!/bin/sh
pip install setuptools || true
pip install pypi-timemachine
pypi-timemachine 2022-10-13 --port 9876 &
pip config set global.index-url http://127.0.0.1:9876/
sleep 3
pip install pytest-rerunfailures
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"

cd /app
set -e

echo "================= 0909 INSTALLING DEPENDENCIES 0909 ================="
yarn install --frozen-lockfile

export PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
export PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium

echo "================= 0909 BUILDING PROJECT 0909 ================="
yarn run build:compile

echo "================= 0909 BUILD START 0909 ================="
if [ ! -f src/component-index.js ]; then
    echo "Creating component-index.js file"
    echo "// Auto-generated component index for tests" > src/component-index.js
    echo "export const components = {};" >> src/component-index.js
fi

export NODE_ENV=test
export CI=true

echo "================= 0909 BUILD END 0909 ================="

EOFBUILD
RUN chmod +x /build.sh
RUN /build.sh
