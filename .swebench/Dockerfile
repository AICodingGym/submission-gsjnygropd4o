###############################################
# BASE IMAGE
###############################################
FROM python:3.8-slim

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
RUN git checkout 7eee2454f617569fd6889f2211f75bc02a35f9f8



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

git reset --hard 2ad10ffe43baaa849acdfa3a9dedfc1824c021d3
git clean -fdx
git checkout 2ad10ffe43baaa849acdfa3a9dedfc1824c021d3


cd /

EOFPREP
RUN chmod +x /preprocess.sh
RUN /preprocess.sh






RUN cat <<'EOFBUILD' > /build.sh
#!/bin/sh
pip install setuptools || true
pip install pypi-timemachine
pypi-timemachine 2021-05-21 --port 9876 &
pip config set global.index-url http://127.0.0.1:9876/
sleep 3
pip install pytest-rerunfailures
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"

cd /app
set -e

pip install --upgrade pip wheel setuptools

pip install "jinja2==2.11.3" "MarkupSafe==1.1.1" PyYAML cryptography packaging

pip install pycrypto passlib pywinrm pytz pexpect

pip install mock pytest pytest-xdist

pip install argparse

pip install -e .

export PYTHONPATH=/app/lib:/app/test/lib:/app/test:$PYTHONPATH
export PATH=/app/bin:$PATH
export ANSIBLE_VERBOSITY=1

echo "================= 0909 BUILD START 0909 ================="
echo "Ansible installation completed successfully"
echo "Python path: $PYTHONPATH"
echo "================= 0909 BUILD END 0909 ================="

EOFBUILD
RUN chmod +x /build.sh
RUN /build.sh
