#!/bin/bash
set -x

# ENV exports from Dockerfiles
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60

cd /app

git reset --hard b6edc5e46af598a3c187d917ad42b2d013e4dfee
git checkout b6edc5e46af598a3c187d917ad42b2d013e4dfee

# Apply user patch
git apply -v /workspace/patch.diff || echo 'WARNING: patch apply failed'

# Apply test setup (mirrors before_repo_set_cmd)
git checkout 72d06db14d58692bfb4d07b1aa745a37b35956f3 -- internal/server/audit/logfile/logfile_test.go

# Run tests
bash /workspace/run_script.sh TestNewSink_ExistingFile,TestNewSink_Error,TestNewSink_NewFile,TestNewSink_DirNotExists,TestSink_SendAudits > /workspace/stdout.log 2> /workspace/stderr.log

# Parse results
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json || true

# Print outputs for GHA log
echo '=== STDOUT ==='
cat /workspace/stdout.log 2>/dev/null || true
echo '=== STDERR ==='
cat /workspace/stderr.log 2>/dev/null || true
echo '=== PARSED OUTPUT ==='
cat /workspace/output.json 2>/dev/null || true

# Exit non-zero if any test failed
python -c "
import json, sys
try:
    with open('/workspace/output.json') as f:
        data = json.load(f)
    failed = [t for t in data.get('tests', []) if t.get('status') == 'FAILED']
    if failed:
        print(f'{len(failed)} test(s) FAILED')
        sys.exit(1)
    print('All tests passed')
except Exception as e:
    print(f'Could not check results: {e}')
    sys.exit(1)
"
