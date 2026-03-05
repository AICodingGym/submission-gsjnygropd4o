###############################################
# BASE IMAGE
###############################################
FROM 084828598639.dkr.ecr.us-west-2.amazonaws.com/docker-hub/library/python:3.11-slim

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
    build-essential \
    libglib2.0-0 \
    libgl1 \
    libegl1 \
    libxkbcommon0 \
    libdbus-1-3 \
    libxcomposite1 \
    libxdamage1 \
    libxi6 \
    libxrandr2 \
    libxfixes3 \
    libxcursor1 \
    libxrender1 \
    libxext6 \
    xvfb \
    libnss3 \
    libxss1 \
    libasound2 \
    libxtst6 \
    libxslt1.1 \
    fonts-liberation2 \
    libxcb1 \
    libxkbcommon-x11-0 \
    libgl1-mesa-glx \
    dbus-x11 \
    python3-dev \
    python-is-python3 \
    && rm -rf /var/lib/apt/lists/*

###############################################
# REPO SETUP
###############################################
RUN git clone https://github.com/qutebrowser/qutebrowser.git .
RUN git checkout 363c8a7e5ccdf6968fc7ab84a2053ac78036691d



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

git reset --hard 09925f74817cf7a970f166342f81886a1d27ee35
git clean -fdx
git checkout 09925f74817cf7a970f166342f81886a1d27ee35


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

pip install -e .

pip install PyQt5==5.15.9 PyQt5-Qt5==5.15.2 PyQt5-sip==12.12.2 PyQtWebEngine==5.15.6 PyQtWebEngine-Qt5==5.15.2

pip install attrs==23.1.0 beautifulsoup4==4.12.2 blinker==1.6.2 certifi==2023.7.22 charset-normalizer==3.2.0 cheroot==10.0.0 click==8.1.7 coverage==7.3.1 exceptiongroup==1.1.3 execnet==2.0.2 filelock==3.12.4 Flask==2.3.3 hunter==3.6.1 hypothesis==6.86.1 idna==3.4 importlib-metadata==6.8.0 iniconfig==2.0.0 itsdangerous==2.1.2 jaraco.functools==3.9.0 Mako==1.2.4 manhole==1.8.0 more-itertools==10.1.0 packaging==23.1 parse==1.19.1 parse-type==0.6.2 pluggy==1.3.0 py-cpuinfo==9.0.0 Pygments==2.16.1 pytest==7.4.2 pytest-bdd==6.1.1 pytest-benchmark==4.0.0 pytest-cov==4.1.0 pytest-instafail==0.5.0 pytest-mock==3.11.1 pytest-qt==4.2.0 pytest-repeat==0.9.1 pytest-rerunfailures==12.0 pytest-xdist==3.3.1 pytest-xvfb==3.0.0 PyVirtualDisplay==3.0 requests==2.31.0 requests-file==1.5.1 six==1.16.0 sortedcontainers==2.4.0 soupsieve==2.5 tldextract==3.5.0 toml==0.10.2 tomli==2.0.1 typing_extensions==4.8.0 urllib3==2.0.4 vulture==2.9.1 Werkzeug==2.3.7 zipp==3.16.2

export PYTEST_QT_API=pyqt5
export QUTE_QT_WRAPPER=PyQt5

echo "================= 0909 BUILD START 0909 ================="
echo "================= 0909 BUILD END 0909 ================="

EOFBUILD
RUN chmod +x /build.sh
RUN /build.sh
