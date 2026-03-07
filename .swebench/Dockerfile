# syntax=docker/dockerfile:1
###############################################
# BASE IMAGE
###############################################
FROM 084828598639.dkr.ecr.us-west-2.amazonaws.com/docker-hub/library/ubuntu:20.04

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
# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install required system dependencies
RUN apt-get update && apt-get install -y \
    git \
    python3 \
    python3-pip \
    python3-dev \
    python3-venv \
    python-is-python3 \
    # Qt5 and GUI dependencies - avoid system PyQt5 to prevent conflicts
    qt5-default \
    qtbase5-dev \
    qtdeclarative5-dev \
    qtwebengine5-dev \
    # X11 and display dependencies for headless testing
    xvfb \
    xauth \
    x11-utils \
    dbus-x11 \
    # Additional system dependencies from CI
    libyaml-dev \
    libegl1 \
    libxkbcommon-x11-0 \
    libxcb-icccm4 \
    libxcb-image0 \
    libxcb-keysyms1 \
    libxcb-randr0 \
    libxcb-render-util0 \
    libxcb-xinerama0 \
    # Font for GUI tests
    ttf-bitstream-vera \
    # Build tools
    gcc \
    libfontconfig1 \
    libxkbcommon0 \
    libegl1 \
    && rm -rf /var/lib/apt/lists/*

# Set up display environment for headless testing
ENV DISPLAY=:99
ENV QT_QPA_PLATFORM=offscreen

###############################################
# REPO SETUP
###############################################
RUN git clone https://github.com/qutebrowser/qutebrowser.git .

# Freeze the repository to the specific commit
RUN git checkout 5fc38aaf22415ab0b70567368332beee7955b367



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

git reset --hard 6d9c28ce10832aa727de1a326d9459a035ff3aba
git clean -fdx
git checkout 6d9c28ce10832aa727de1a326d9459a035ff3aba


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
pip install "setuptools<69" || true
pip install pytest-rerunfailures
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"

cd /app
set -e

echo "Installing Python dependencies..."
pip3 install --upgrade pip setuptools==59.6.0 wheel

pip3 install "jaraco.functools>=1.20"

pip3 install -r requirements.txt

pip3 install -r misc/requirements/requirements-pyqt-5.15.txt

pip3 install -r misc/requirements/requirements-tests.txt

pip3 install tox

pip3 install --force-reinstall "urllib3>=1.21.1,<1.26" "chardet>=3.0.2,<4" "requests>=2.20.0,<3.0.0"

export PYTEST_QT_API=pyqt5
export QT_QPA_PLATFORM=offscreen
export DISPLAY=:99

echo "================= 0909 BUILD START 0909 ================="
pip3 install -e .
echo "================= 0909 BUILD END 0909 ================="

EOFBUILD
RUN chmod +x /build.sh
RUN /build.sh
