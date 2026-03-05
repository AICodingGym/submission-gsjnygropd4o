###############################################
# BASE IMAGE
###############################################
FROM golang:1.22-alpine

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
RUN apk update && apk add --no-cache \
    git \
    bash \
    build-base \
    python3 \
    py3-pip \
    py3-setuptools \
    make \
    gcc \
    musl-dev && \
    ln -sf python3 /usr/bin/python

###############################################
# REPOSITORY SETUP
###############################################
RUN git clone https://github.com/future-architect/vuls.git .
# If the repository uses submodules, uncomment the following line
# RUN git submodule update --init --recursive

# Freeze the repository to a reproducible state.
# Use one of the two approaches below depending on the task version:

# - If the task version is "latest" or there is no specified version, freeze to the latest commit before a given date:
# RUN LATEST_COMMIT=$(git rev-list -n 1 --before="2025-03-28" HEAD) && git reset --hard $LATEST_COMMIT

# - If the task version is NOT "latest" (e.g., a specific commit hash), pin to a specific commit explicitly (use this only when needed):
RUN git checkout 73dc95f6b90883d8a87e01e5e9bb6d3cc32add6d

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

git reset --hard dce837950529084d34c6815fa66e59a4f68fa8e4
git clean -fdx
git checkout dce837950529084d34c6815fa66e59a4f68fa8e4


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

go mod download

export CGO_ENABLED=0

echo "================= BUILD START ================="
go build -v ./...
echo "================= BUILD END ================="

EOFBUILD
RUN chmod +x /build.sh
RUN /build.sh
