###############################################
# BASE IMAGE
###############################################
FROM node:22-bullseye

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
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    build-essential \
    python3 \
    python3-pip \
    python3-setuptools \
    python-is-python3 \
    bash \
    curl \
    ca-certificates \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

###############################################
# REPO SETUP
###############################################
# Clone repository
RUN git clone https://github.com/element-hq/element-web.git .
# We need to freeze the repo, check it out to a fixed date. Do not edit any code below this section.
RUN LATEST_COMMIT=$(git rev-list -n 1 --before="2025-05-05" HEAD) && git reset --hard $LATEST_COMMIT

###############################################
# ENTRYPOINT / CMD
###############################################
# ENTRYPOINT should always be /bin/bash. If the build and test commands are set as CMD or ENTRYPOINT,
# convert them to RUN commands and move them to the previous sections.
ENTRYPOINT ["/bin/bash"]

# --- instance layer (merged from instance Dockerfile) ---

# Write preprocess and build scripts
ENV PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
ENV UV_HTTP_TIMEOUT=60

RUN cat <<'EOFPREP' > /preprocess.sh
#!/bin/bash

cd /app

git reset --hard ec6bb880682286216458d73560aa91746d4f099b
git clean -fdx
git checkout ec6bb880682286216458d73560aa91746d4f099b


cd /

EOFPREP
RUN chmod +x /preprocess.sh
RUN /preprocess.sh






RUN cat <<'EOFBUILD' > /build.sh
#!/bin/sh
pip install setuptools || true
pip install pypi-timemachine
pypi-timemachine 2022-01-19 --port 9876 &
pip config set global.index-url http://127.0.0.1:9876/
sleep 3
pip install pytest-rerunfailures
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"

cd /app
set -e

###############################################
# PACKAGE MANAGER DETECTION AND INSTALLATION
###############################################
# This script installs dependencies based on the detected lockfile.
# Supported managers: npm, yarn, pnpm, bun.
# If no lockfile is found, it falls back to pinning minimal versions via semver.

if [ -f "package-lock.json" ]; then
  echo "📦 Detected npm lockfile. Installing dependencies with npm ci"
  npm ci --ignore-scripts --loglevel info

elif [ -f "yarn.lock" ]; then
  echo "📦 Detected yarn lockfile. Installing dependencies with yarn"
  yarn install --ignore-scripts --frozen-lockfile

elif [ -f "pnpm-lock.yaml" ]; then
  echo "📦 Detected pnpm lockfile. Installing dependencies with pnpm"
  pnpm install --ignore-scripts --frozen-lockfile

elif [ -f "bun.lockb" ]; then
  echo "📦 Detected bun lockfile. Installing dependencies with bun"
  bun install --no-scripts

else
  echo "⚠️ No lockfile found. Falling back to minimal compatible version pinning"

  ###############################################
  # INSTALL REQUIRED TOOLS
  ###############################################
  echo "📥 Installing semver for version pinning"
  npm install --save-dev semver

  ###############################################
  # PIN MINIMAL COMPATIBLE VERSIONS IN package.json
  ###############################################
  echo "📌 Pinning minimal compatible versions in package.json"
  node <<'EOF'
const fs = require('fs');
const semver = require('semver');

const pkg = JSON.parse(fs.readFileSync('package.json', 'utf8'));

function pin(deps) {
  if (!pkg[deps]) return;
  for (const name of Object.keys(pkg[deps])) {
    const range = pkg[deps][name];
    if (range.startsWith("file:") || range.startsWith("link:") || range.startsWith("git:") || range.includes("/")) {
      console.log(`🔁 Skipping ${name} (${range})`);
      continue;
    }
    const minVersion = semver.minVersion(range);
    if (minVersion) {
      pkg[deps][name] = minVersion.version;
      console.log(`📌 Pinned ${name} to ${minVersion.version} (from "${range}")`);
    } else {
      console.warn(`⚠️ Unable to pin ${name} — invalid range: ${range}`);
    }
  }
}

pin('dependencies');
pin('devDependencies');
pin('optionalDependencies');
pin('peerDependencies');

fs.writeFileSync('package.json', JSON.stringify(pkg, null, 2));
console.log('✅ package.json pinned to minimal versions');
EOF

  ###############################################
  # INSTALL DEPENDENCIES AFTER PINNING
  ###############################################
  echo "📦 Installing pinned dependencies with npm"
  rm -f package-lock.json
  npm install --ignore-scripts --loglevel info

  ###############################################
  # CLEANUP
  ###############################################
  echo "🧹 Cleaning up semver"
  npm uninstall semver || true
fi

###############################################
# ENVIRONMENT VARIABLES (OPTIONAL)
###############################################
# TODO: Set any needed environment variables here
# export NODE_ENV=development

###############################################
# BUILD STEP (OPTIONAL)
###############################################
echo "================= 0909 BUILD START 0909 ================="
# TODO: Uncomment if a build step is needed
# npm run build
echo "================= 0909 BUILD END 0909 ================="

EOF
