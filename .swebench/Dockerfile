###############################################
# BASE IMAGE
###############################################
FROM ubuntu:20.04

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
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y \
    git \
    build-essential \
    libffi-dev \
    libssl-dev \
    libyaml-dev \
    python3.9 \
    python3.9-dev \
    python3.9-venv \
    python3-pip \
    openssh-client \
    rsync \
    curl \
    unzip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && ln -sf /usr/bin/python3.9 /usr/bin/python3 \
    && ln -sf /usr/bin/python3 /usr/bin/python

###############################################
# REPO SETUP
###############################################
RUN git clone https://github.com/ansible/ansible .

# Freeze the repository to a reproducible state.
RUN git checkout ba6da65a0f3baefda7a058ebbd0a8dcafb8512f5



###############################################
# ENTRYPOINT / CMD
###############################################
CMD ["bash"]

# --- instance layer (merged from instance Dockerfile) ---

# Write preprocess and build scripts
ENV PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
ENV UV_HTTP_TIMEOUT=60

RUN cat <<'EOFPREP' > /preprocess.sh
#!/bin/bash

cd /app

git reset --hard 0044091a055dd9cd448f7639a65b7e8cc3dacbf1
git clean -fdx
git checkout 0044091a055dd9cd448f7639a65b7e8cc3dacbf1


cd /

EOFPREP
RUN chmod +x /preprocess.sh
RUN /preprocess.sh






RUN cat <<'EOFBUILD' > /build.sh
#!/bin/sh
pip install setuptools || true
pip install pypi-timemachine
pypi-timemachine 2020-12-14 --port 9876 &
pip config set global.index-url http://127.0.0.1:9876/
sleep 3
pip install pytest-rerunfailures
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"

cd /app
set -e

apt-get update && apt-get install -y python3-pip
python3 -m pip install --upgrade pip setuptools wheel

python3 -m pip install -r requirements.txt

python3 -m pip install .

python3 -m pip install -r test/units/requirements.txt

python3 -m pip install -r test/lib/ansible_test/_data/requirements/units.txt

python3 -m pip install pytest pytest-xdist pytest-forked mock pyyaml jinja2 cryptography

export PYTHONPATH=/app:$PYTHONPATH

echo "================= 0909 BUILD START 0909 ================="
echo "Ansible is ready for testing"
echo "================= 0909 BUILD END 0909 ================="

EOFBUILD
RUN chmod +x /build.sh
RUN /build.sh
