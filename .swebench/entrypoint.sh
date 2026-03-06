#!/bin/bash
set -x

# ENV exports from Dockerfiles
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60

cd /app

git reset --hard a19634474246739027f826968ea34e720c0ec987
git checkout a19634474246739027f826968ea34e720c0ec987

# Apply user patch
git apply -v /workspace/patch.diff || echo 'WARNING: patch apply failed'

# Apply test setup (mirrors before_repo_set_cmd)
git checkout 3fd8e12949b8feda401930574facf09dd4180bba -- scripts/dev/quit_segfault_test.sh tests/end2end/features/completion.feature tests/end2end/features/editor.feature tests/end2end/features/misc.feature tests/end2end/features/private.feature tests/end2end/features/prompts.feature tests/end2end/features/search.feature tests/end2end/features/tabs.feature tests/end2end/features/utilcmds.feature tests/end2end/fixtures/quteprocess.py tests/unit/misc/test_utilcmds.py

# Run tests
bash /workspace/run_script.sh tests/unit/misc/test_utilcmds.py,tests/end2end/fixtures/quteprocess.py > /workspace/stdout.log 2> /workspace/stderr.log

# Parse results
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json || true

# Print outputs for GHA log
echo '=== STDOUT ==='
cat /workspace/stdout.log 2>/dev/null || true
echo '=== STDERR ==='
cat /workspace/stderr.log 2>/dev/null || true
echo '=== PARSED OUTPUT ==='
cat /workspace/output.json 2>/dev/null || true

# Exit non-zero if any test failed or errored
python -c "
import json, sys
try:
    with open('/workspace/output.json') as f:
        data = json.load(f)
    tests = data.get('tests', [])
    failed = [t for t in tests if t.get('status') in ('FAILED', 'ERROR')]
    if failed:
        print(f'{len(failed)} test(s) FAILED/ERROR')
        sys.exit(1)
    if not tests:
        print('No tests found')
        sys.exit(1)
    print('All tests passed')
except Exception as e:
    print(f'Could not check results: {e}')
    sys.exit(1)
"
