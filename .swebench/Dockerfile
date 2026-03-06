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
    python3-dev \
    build-essential \
    pkg-config \
    libgl1 \
    libegl1 \
    libglib2.0-0 \
    libnss3 \
    libnspr4 \
    libatk-bridge2.0-0 \
    libdrm2 \
    libxcomposite1 \
    libxdamage1 \
    libasound2 \
    libxkbcommon-x11-0 \
    libxcb-icccm4 \
    libxcb-image0 \
    libxcb-keysyms1 \
    libxcb-randr0 \
    libxcb-render-util0 \
    libxcb-xinerama0 \
    libxcb-xfixes0 \
    libxcb-cursor0 \
    libxcb-shape0 \
    libxcb-util1 \
    libxcursor1 \
    libfontconfig1 \
    libfreetype6 \
    libx11-6 \
    libx11-xcb1 \
    libxext6 \
    libxrender1 \
    xvfb \
    x11-utils \
    dbus-x11 \
    libasound2-dev \
    libpulse-dev \
    fonts-liberation \
    fonts-dejavu-core \
    libxss1 \
    libxtst6 \
    libxrandr2 \
    libxfixes3 \
    libxi6 \
    && rm -rf /var/lib/apt/lists/*

###############################################
# REPO SETUP
###############################################
RUN git clone https://github.com/qutebrowser/qutebrowser.git .
RUN git checkout 059c6fdc75567943479b23ebca7c07b5e9a7f34c



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

git reset --hard def864adc8b19bdbc506919270d8ff1408b4faac
git clean -fdx
git checkout def864adc8b19bdbc506919270d8ff1408b4faac


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

pip install --upgrade pip
pip install -r requirements.txt
pip install -r misc/requirements/requirements-tests.txt
pip install -r misc/requirements/requirements-pyqt.txt
pip install -e .

export QT_QPA_PLATFORM=offscreen
export DISPLAY=:99
export PYTEST_QT_API=pyqt5
export QUTE_QT_WRAPPER=PyQt5
export QTWEBENGINE_CHROMIUM_FLAGS="--no-sandbox --disable-dev-shm-usage --disable-gpu --disable-extensions --disable-plugins --disable-background-timer-throttling --disable-renderer-backgrounding --disable-backgrounding-occluded-windows"
export QTWEBENGINE_DISABLE_SANDBOX=1

echo "================= 0909 BUILD START 0909 ================="
python -c "import qutebrowser; print('qutebrowser imported successfully')"
QT_QPA_PLATFORM=offscreen python -c "from PyQt5.QtWidgets import QApplication; print('PyQt5 imported successfully')"
echo "================= 0909 BUILD END 0909 ================="

EOFBUILD
RUN chmod +x /build.sh
RUN /build.sh
