# syntax=docker/dockerfile:1
###############################################
# BASE IMAGE
###############################################
FROM python:3.11-slim

###############################################
# WORKING DIRECTORY
###############################################
RUN mkdir /app
WORKDIR /app

###############################################
# SYSTEM DEPENDENCIES
###############################################
RUN apt-get update && apt-get install -y \
    git \
    bash \
    python3 \
    libegl1 \
    libxkbcommon-x11-0 \
    libxcb-icccm4 \
    libxcb-image0 \
    libxcb-keysyms1 \
    libxcb-randr0 \
    libxcb-render-util0 \
    libxcb-xinerama0 \
    libxcb-shape0 \
    libxcb-cursor0 \
    xvfb \
    dbus-x11 \
    build-essential \
    libglib2.0-0 \
    libgl1 \
    libfontconfig1 \
    libxrender1 \
    libdbus-1-3 \
    libnss3 \
    libnspr4 \
    libxss1 \
    libasound2 \
    libxcomposite1 \
    libxdamage1 \
    libxrandr2 \
    libatk-bridge2.0-0 \
    libdrm2 \
    libxkbcommon0 \
    libgtk-3-0 \
    && rm -rf /var/lib/apt/lists/*

###############################################
# REPO SETUP
###############################################
RUN git clone https://github.com/qutebrowser/qutebrowser.git .
RUN git checkout 488d33dd1b2540b234cbb0468af6b6614941ce8f



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

git reset --hard 7691556ea171c241eabb76e65c64c90dfc354327
git clean -fdx
git checkout 7691556ea171c241eabb76e65c64c90dfc354327


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

pip install -r requirements.txt
pip install -r misc/requirements/requirements-tests.txt
pip install -r misc/requirements/requirements-pyqt.txt

export QT_QPA_PLATFORM=offscreen
export DISPLAY=:99

echo "================= 0909 BUILD START 0909 ================="
echo "qutebrowser dependencies installed successfully"
echo "================= 0909 BUILD END 0909 ================="

EOFBUILD
RUN chmod +x /build.sh
RUN /build.sh
