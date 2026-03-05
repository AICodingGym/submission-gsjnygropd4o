###############################################
# BASE IMAGE
###############################################
FROM python:3.12-slim

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
# Setup basic python environment which is needed for final post-processing and scoring
RUN apt-get update && apt-get install -y \
    git \
    build-essential \
    libffi-dev \
    libssl-dev \
    openssh-client \
    sshpass \
    rsync \
    unzip \
    zip \
    tar \
    gzip \
    iptables \
    iputils-ping \
    net-tools \
    procps \
    && rm -rf /var/lib/apt/lists/*

# Ensure python3 is available as python
RUN ln -sf /usr/local/bin/python3 /usr/local/bin/python

###############################################
# REPO SETUP
###############################################
# Clone repository, follow the template below
RUN git clone https://github.com/ansible/ansible.git .

# Freeze the repository to a reproducible state.
# Pin to a specific commit explicitly
RUN git checkout 6382ea168a93d80a64aab1fbd8c4f02dc5ada5bf



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

git reset --hard 9ab63986ad528a6ad5bf4c59fe104d5106d6ef9b
git clean -fdx
git checkout 9ab63986ad528a6ad5bf4c59fe104d5106d6ef9b


cd /

EOFPREP
RUN chmod +x /preprocess.sh
RUN /preprocess.sh






RUN cat <<'EOFBUILD' > /build.sh
#!/bin/sh
pip install setuptools || true
pip install pypi-timemachine
pypi-timemachine 2024-09-19 --port 9876 &
pip config set global.index-url http://127.0.0.1:9876/
sleep 3
pip install pytest-rerunfailures
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"

cd /app
set -e

pip install --upgrade pip setuptools wheel
pip install -r requirements.txt
pip install -e .

pip install pytest pytest-xdist coverage

echo "================= 0909 BUILD START 0909 ================="
python -c "import ansible; print('Ansible version:', ansible.__version__)"
echo "================= 0909 BUILD END 0909 ================="

EOFBUILD
RUN chmod +x /build.sh
RUN /build.sh
