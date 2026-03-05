#!/bin/bash
set -x

# ENV exports from Dockerfiles
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60

cd /app

git reset --hard 01f583bb025dbd60e4210eb9a31a6f859ed150e8
git checkout 01f583bb025dbd60e4210eb9a31a6f859ed150e8

# Apply user patch
git apply -v /workspace/patch.diff || echo 'WARNING: patch apply failed'

# Apply test setup (mirrors before_repo_set_cmd)
git checkout 2eac0df47b5ecc8bb05002d80383ceb08ab3620a -- internal/telemetry/telemetry_test.go

# Run tests
bash /workspace/run_script.sh TestPing_Existing,TestPing,TestPing_SpecifyStateDir > /workspace/stdout.log 2> /workspace/stderr.log

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
