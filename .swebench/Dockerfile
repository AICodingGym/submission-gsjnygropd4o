# syntax=docker/dockerfile:1
###############################################
# BASE IMAGE
###############################################
FROM python:3.11-slim

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
RUN apt-get update && apt-get install -y \
    git \
    bash \
    make \
    gcc \
    libffi-dev \
    libssl-dev \
    python-is-python3 \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

###############################################
# REPO SETUP
###############################################
RUN git clone https://github.com/ansible/ansible.git .
RUN git checkout 906c969b551b346ef54a2c0b41e04f632b7b73c2



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

git reset --hard 57596edcca0ef3bc4d0d90a55d33ac433b407abb
git clean -fdx
git checkout 57596edcca0ef3bc4d0d90a55d33ac433b407abb


cd /

EOFPREP
RUN chmod +x /preprocess.sh
RUN /preprocess.sh






RUN cat <<'EOFBUILD' > /build.sh
#!/bin/sh
pip install setuptools || true
pip install pypi-timemachine
pypi-timemachine 2025-08-26 --port 9876 &
pip config set global.index-url http://127.0.0.1:9876/
sleep 3
pip install pytest-rerunfailures
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"

cd /app
set -e

pip install --upgrade pip wheel setuptools

if [ -f requirements.txt ]; then
    pip install -r requirements.txt
fi

if [ -f test/units/requirements.txt ]; then
    pip install -r test/units/requirements.txt
fi

if [ -f test/lib/ansible_test/_data/requirements/units.txt ]; then
    pip install -r test/lib/ansible_test/_data/requirements/units.txt
fi

if [ -f test/lib/ansible_test/_data/requirements/ansible-test.txt ]; then
    pip install -r test/lib/ansible_test/_data/requirements/ansible-test.txt
fi

pip install pytest pytest-xdist pytest-mock pytest-forked mock pyyaml
pip install bcrypt passlib pexpect pywinrm

pip install -e .

export PYTHONPATH=/app:$PYTHONPATH
export PATH=/app/bin:$PATH
export ANSIBLE_VERBOSITY=3

echo "================= 0909 BUILD START 0909 ================="
mkdir -p /app/test/results
echo "================= 0909 BUILD END 0909 ================="

EOFBUILD
RUN chmod +x /build.sh
RUN pip install "setuptools<71" && /build.sh
