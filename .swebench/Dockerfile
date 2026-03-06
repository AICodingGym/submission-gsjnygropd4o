# syntax=docker/dockerfile:1
###############################################
# BASE IMAGE
###############################################
FROM python:3.9-slim

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
    bash \
    make \
    gcc \
    libssl-dev \
    libffi-dev \
    python3-dev \
    curl \
    openssh-client \
    sshpass \
    python-is-python3 \
    && rm -rf /var/lib/apt/lists/*

###############################################
# REPO SETUP
###############################################
# Clone repository and checkout specific commit
RUN git clone https://github.com/ansible/ansible.git .
RUN git checkout 1055803c3a812189a1133297f7f5468579283f86



###############################################
# ENTRYPOINT / CMD
###############################################
# ENTRYPOINT should always be /bin/bash
ENTRYPOINT ["/bin/bash"]

# --- instance layer (merged from instance Dockerfile) ---

# Write preprocess and build scripts
ENV PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
ENV UV_HTTP_TIMEOUT=60

RUN cat <<'EOFPREP' > /preprocess.sh
#!/bin/bash

cd /app

git reset --hard 341a6be78d7fc1701b0b120fc9df1c913a12948c
git clean -fdx
git checkout 341a6be78d7fc1701b0b120fc9df1c913a12948c


cd /

EOFPREP
RUN chmod +x /preprocess.sh
RUN /preprocess.sh






RUN cat <<'EOFBUILD' > /build.sh
#!/bin/sh
pip install setuptools || true
pip install pypi-timemachine
pypi-timemachine 2020-05-27 --port 9876 &
pip config set global.index-url http://127.0.0.1:9876/
sleep 3
pip install pytest-rerunfailures
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"

cd /app
set -e

echo "Installing pip and upgrading setuptools..."
pip install -U pip setuptools wheel

echo "Installing Ansible core dependencies..."
pip install -r requirements.txt

echo "Installing Ansible test dependencies..."
pip install -r test/lib/ansible_test/_data/requirements/units.txt
pip install -r test/units/requirements.txt

echo "Installing pytest and additional dependencies..."
pip install pytest pytest-xdist pytest-mock mock cryptography jinja2 PyYAML
pip install pytest-forked pytest-cov

echo "Setting up ansible-test..."
chmod +x /app/bin/ansible-test

export PYTHONPATH=/app:$PYTHONPATH
export PATH=/app/bin:$PATH

echo "================= 0909 BUILD START 0909 ================="
echo "Setting up Ansible for development..."
python setup.py develop

echo "Verifying Ansible installation..."
ansible --version

echo "Verifying pytest installation..."
python -m pytest --version

echo "Verifying ansible-test..."
ls -la /app/bin/ansible-test
echo "================= 0909 BUILD END 0909 ================="

EOFBUILD
RUN chmod +x /build.sh
RUN pip install "setuptools<71" && /build.sh
