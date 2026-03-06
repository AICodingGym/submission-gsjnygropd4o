# syntax=docker/dockerfile:1
###############################################
# BASE IMAGE
###############################################
# TODO: Choose appropriate base image
FROM golang:1.24

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
ENV PIP_BREAK_SYSTEM_PACKAGES=1
###############################################
# TODO: Install required system dependencies
# TODO: Setup basic python environment which is needed for final post-processing and scoring
# RUN apt-get update && apt-get install -y git <other-required-packages>
RUN apt-get update && apt-get install -y \
    curl \
    git \
    pkg-config \
    build-essential \
    cmake \
    g++ \
    zlib1g-dev \
    libutfcpp-dev \
    python3 \
    python3-pip \
    python3-setuptools \
    python-is-python3 \
    && rm -rf /var/lib/apt/lists/*

# Install TagLib
RUN curl -L https://github.com/taglib/taglib/archive/refs/heads/master.tar.gz -o /tmp/taglib.tar.gz \
    && tar -xzvf /tmp/taglib.tar.gz -C /tmp \
    && cd /tmp/taglib-master \
    && cmake . \
    && make -j$(nproc) \
    && make install \
    && ldconfig

# Install Node.js fromNodeSource
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*
###############################################
# REPO SETUP
###############################################
# TODO: Clone repository, follow the template below
RUN git clone https://github.com/navidrome/navidrome.git .
# RUN git submodule update --init --recursive
# We need to freeze the repo, check it out to a fixed date. Do not edit any code below this section.
RUN LATEST_COMMIT=$(git rev-list -n 1 --before="2025-04-28" HEAD) && git reset --hard $LATEST_COMMIT

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

git reset --hard 537e2fc033b71a4a69190b74f755ebc352bb4196
git clean -fdx
git checkout 537e2fc033b71a4a69190b74f755ebc352bb4196


cd /

EOFPREP
RUN chmod +x /preprocess.sh
RUN /preprocess.sh






RUN cat <<'EOFBUILD' > /build.sh
#!/bin/sh
pip install setuptools || true
pip install pypi-timemachine
pypi-timemachine 2025-01-12 --port 9876 &
pip config set global.index-url http://127.0.0.1:9876/
sleep 3
pip install pytest-rerunfailures
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"

# Common Setup, DO NOT MODIFY
cd /app
set -e

# COMPLETE THE FOLLOWING SECTIONS
###############################################
# PROJECT DEPENDENCIES AND CONFIGURATION
###############################################
# TODO: Install project dependencies if needed based on relevant config/lock files in the repo.
# Note that we are developing the project, even if dependencies have been installed before, we need to install again to accommodate the changes we made.
# <dependency-installation-commands>
# TODO: Configure project and environment variables
# <config-commands>

###############################################
# BUILD
###############################################
echo "================= 0909 BUILD START 0909 ================="
# TODO: Build the project if needed. Note that we are developing the project and making changes to it, even if it has been build before, we need to build it again.
# Install development tools
make setup
# Build the project to verify the installation
make build
echo "================= 0909 BUILD END 0909 ================="
EOFBUILD
RUN chmod +x /build.sh
RUN /build.sh
