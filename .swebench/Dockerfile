###############################################
# BASE IMAGE
###############################################
# Use the appropriate official Go base image (Debian Bookworm based)
FROM golang:1.24-bookworm

###############################################
# WORKING DIRECTORY
###############################################
# The repository should always be cloned into /app
# DO NOT MODIFY THIS SECTION
RUN mkdir /app
WORKDIR /app

###############################################
# SYSTEM DEPENDENCIES
###############################################
# Install required system dependencies using apt-get for Debian
# Ensure a basic Python environment is installed, necessary for final parsing and scoring
# Required system packages:
# - git
# - bash
# - build-essential (Debian equivalent for build-base)
# - python3
# - python3-pip (Debian package name)
# - python3-setuptools (Debian package name)
# - nodejs
# - npm
# - openssl
# - mariadb-server
# - mariadb-client
# - wget (Required for Grafana download)
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    bash \
    build-essential \
    python3 \
    python3-pip \
    python3-setuptools \
    python-is-python3 \
    openssl \
    clang \
    unzip \
    gcc \
    nodejs \
    npm \
    wget \
    # Clean up apt cache to reduce image size
    && rm -rf /var/lib/apt/lists/*

# Remove existing python binary if it exists (optional, might not be needed on modern Debian)
# The -f flag prevents errors if the file doesn't exist
RUN rm -f /usr/bin/python

# Create a symbolic link to ensure python points to python3
# This might already be handled by the system or a package like python-is-python3,
# but creating it explicitly ensures compatibility with scripts expecting 'python'.
RUN ln -s /usr/bin/python3 /usr/bin/python

###############################################
# REPOSITORY SETUP
###############################################
# Clone your repository using the template below
# Using '.' as the target directory clones into the current WORKDIR (/app)
RUN git clone https://github.com/future-architect/vuls.git .
# If the repository uses submodules, uncomment the following line
# RUN git submodule update --init --recursive

# Freeze the repository at a specific commit before the given date
# DO NOT MODIFY THE FOLLOWING COMMAND
RUN LATEST_COMMIT=$(git rev-list -n 1 --before="2025-05-30" HEAD) && git reset --hard $LATEST_COMMIT

###############################################
# ENTRYPOINT
###############################################
# The ENTRYPOINT should always be /bin/bash
# DO NOT MODIFY THIS SECTION
ENTRYPOINT ["/bin/bash"]

# --- instance layer (merged from instance Dockerfile) ---

# Write preprocess and build scripts
ENV PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
ENV UV_HTTP_TIMEOUT=60

RUN cat <<'EOFPREP' > /preprocess.sh
#!/bin/bash

cd /app

git reset --hard 7c209cc9dc71e30bf762677d6a380ddc93d551ec
git clean -fdx
git checkout 7c209cc9dc71e30bf762677d6a380ddc93d551ec


cd /

EOFPREP
RUN chmod +x /preprocess.sh
RUN /preprocess.sh






RUN cat <<'EOFBUILD' > /build.sh
#!/bin/sh
pip install setuptools || true
pip install pypi-timemachine
pypi-timemachine 2022-02-03 --port 9876 &
pip config set global.index-url http://127.0.0.1:9876/
sleep 3
pip install pytest-rerunfailures
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"

# Common Setup, DO NOT MODIFY
cd /app
set -e

###############################################
# PROJECT DEPENDENCIES AND CONFIGURATION
###############################################
# Install Go module dependencies from the go.mod/go.sum files.
# Even if dependencies are pre-installed, reinstall to reflect recent changes.
go mod download

# Configure any necessary environment variables for the build.
# Example:
# export YOUR_ENV_VARIABLE=value
# For this project, no specific environment variables are needed.

###############################################
# BUILD
###############################################
echo "================= BUILD START ================="
# Build the Go project.
# go build -v ./...
echo "================= BUILD END ================="
EOFBUILD
RUN chmod +x /build.sh
RUN /build.sh
