###############################################
# BASE IMAGE
###############################################
FROM golang:1.23.1-alpine

###############################################
# WORKING DIRECTORY
###############################################
RUN mkdir /app
WORKDIR /app

###############################################
# SYSTEM DEPENDENCIES
###############################################
RUN apk update && apk add --no-cache \
    git \
    bash \
    build-base \
    python3 \
    py3-pip \
    py3-setuptools \
    ca-certificates \
    curl \
    linux-pam-dev \
    pcsc-lite-dev \
    openssl-dev \
    pkgconfig \
    elfutils-dev \
    clang \
    llvm \
    rsync \
    openssh-client \
    net-tools \
    sudo \
    musl-dev \
    gcompat

###############################################
# REPOSITORY SETUP
###############################################
RUN git clone https://github.com/gravitational/teleport.git .
RUN git checkout ee9b09fb20c43af7e520f57e9239bbcf46b7113d

###############################################
# PROJECT DEPENDENCIES AND CONFIGURATION
###############################################




###############################################
# ENTRYPOINT
###############################################
ENTRYPOINT ["/bin/bash"]

# --- instance layer (merged from instance Dockerfile) ---

# Write preprocess and build scripts
ENV PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
ENV UV_HTTP_TIMEOUT=60

RUN cat <<'EOFPREP' > /preprocess.sh
#!/bin/bash

cd /app

git reset --hard 883cf1aeda25ae67262a9cb255db170937100987
git clean -fdx
git checkout 883cf1aeda25ae67262a9cb255db170937100987


cd /

EOFPREP
RUN chmod +x /preprocess.sh
RUN /preprocess.sh






RUN cat <<'EOFBUILD' > /build.sh
#!/bin/sh
pip install setuptools || true
pip install pypi-timemachine
pypi-timemachine 2023-07-17 --port 9876 &
pip config set global.index-url http://127.0.0.1:9876/
sleep 3
pip install pytest-rerunfailures
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"

cd /app
set -e

go mod download
go mod verify

export CGO_ENABLED=1
export PAM_TAG=pam
export FIPS_TAG=""
export BPF_TAG=""
export LIBFIDO2_TEST_TAG=""
export TOUCHID_TAG=""
export PIV_TEST_TAG=""
export VNETDAEMON_TAG=""

echo "================= BUILD START ================="
go build -v ./lib/... || echo "Lib build had issues, continuing..."
echo "================= BUILD END ================="

EOFBUILD
RUN chmod +x /build.sh
RUN /build.sh
