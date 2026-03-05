###############################################
# BASE IMAGE
###############################################
FROM node:16-bullseye

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
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    bash \
    python3 \
    python3-pip \
    python3-setuptools \
    python-is-python3 \
    build-essential \
    libnode-dev \
    xvfb \
    libgtk-3-0 \
    libgbm-dev \
    libnss3-dev \
    libxss1 \
    libasound2 \
    libsecret-1-dev \
    pkg-config \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# CRITICAL: Verify pip is available after Python installation (needed for parsing.py dependencies)
RUN python -m pip --version && echo "✓ pip is available" || (echo "✗ pip not found" && exit 1)

###############################################
# REPO SETUP
###############################################
RUN git clone https://github.com/tutao/tutanota.git .
RUN git checkout bc0d9ba8f0071fbe982809910959a6ff8884dbbf


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

git reset --hard 6f4d5b9dfc3afe58c74be3be03cab3eb3865aa56
git clean -fdx
git checkout 6f4d5b9dfc3afe58c74be3be03cab3eb3865aa56


cd /

EOFPREP
RUN chmod +x /preprocess.sh
RUN /preprocess.sh






RUN cat <<'EOFBUILD' > /build.sh
#!/bin/sh
pip install setuptools || true
sleep 3
pip install pytest-rerunfailures
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"

cd /app
set -e

python -m pip --version && echo "✓ pip is available" || (echo "✗ pip not found" && exit 1)

echo "Installing dependencies..."
npm ci --ignore-scripts

echo "Building packages..."
npm run build-packages

echo "================= 0909 BUILD START 0909 ================="
echo "Building test environment..."
cd test
node TestBuilder.js
cd /app
echo "================= 0909 BUILD END 0909 ================="

EOFBUILD
RUN chmod +x /build.sh
RUN /build.sh
