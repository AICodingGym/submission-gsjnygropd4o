###############################################
# BASE IMAGE
###############################################
# TODO: Use the appropriate official Go base image
# Example recommended image: golang:1.22-alpine
FROM golang:1.24

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
# TODO: Install required system dependencies
# Ensure a basic Python environment is installed, necessary for final parsing and scoring
# Required system packages:
# - git
# - bash
# - build-base (for compiling C libraries, if needed by Go modules)
# - python3
# - py3-pip
# - py3-setuptools
#
# Example for Debian-based images:
RUN apt-get update && apt-get install -y \
    git \
    bash \
    build-essential \
    python3 \
    python3-pip \
    python3-setuptools \
    python-is-python3 \
    perl \
    && rm -rf /var/lib/apt/lists/*

###############################################
# REPOSITORY SETUP
###############################################
# TODO: Clone your repository using the template below
RUN git clone https://github.com/flipt-io/flipt .
# If the repository uses submodules, uncomment the following line
# RUN git submodule update --init --recursive

# Freeze the repository to a reproducible state.
# Use one of the two approaches below depending on the task version:

# - If the task version is "latest" or there is no specified version, freeze to the latest commit before a given date:
RUN LATEST_COMMIT=$(git rev-list -n 1 --before="2025-05-28" HEAD) && git reset --hard $LATEST_COMMIT

# - If the task version is NOT "latest" (e.g., a specific commit hash), pin to a specific commit explicitly (use this only when needed):
# RUN git checkout <commit-sha-or-tag>

###############################################
# PROJECT DEPENDENCIES AND CONFIGURATION
###############################################
# DO NOT MODIFY THIS SECTION




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

git reset --hard 4e1cd36398ee73acf7d9235b517f05178651c464
git clean -fdx
git checkout 4e1cd36398ee73acf7d9235b517f05178651c464


cd /

EOFPREP
RUN chmod +x /preprocess.sh
RUN /preprocess.sh






RUN cat <<'EOFBUILD' > /build.sh
#!/bin/sh
pip install setuptools || true
pip install pypi-timemachine
pypi-timemachine 2022-09-15 --port 9876 &
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
# TODO: Install Go module dependencies from the go.mod/go.sum files.
# Even if dependencies are pre-installed, reinstall to reflect recent changes.
# Example:
go mod download

# TODO: Configure any necessary environment variables for the build.
# Example:
# export YOUR_ENV_VARIABLE=value


###############################################
# BUILD
###############################################
echo "================= BUILD START ================="
# TODO: Build the Go project.
# Example:
# go build -v ./...
echo "================= BUILD END ================="

EOFBUILD
RUN chmod +x /build.sh
RUN /build.sh
