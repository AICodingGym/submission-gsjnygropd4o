#!/bin/bash
set -x

# ENV exports from Dockerfiles
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60

cd /app

git reset --hard b0317e67523f46f81fc214afd6014d7105d726cc
git checkout b0317e67523f46f81fc214afd6014d7105d726cc

# Apply user patch
git apply -v /workspace/patch.diff || echo 'WARNING: patch apply failed'

# Apply test setup (mirrors before_repo_set_cmd)
git checkout d405160080bbe804f7e9294067d004a7d4dad9d6 -- test/components/views/dialogs/security/ExportE2eKeysDialog-test.tsx test/components/views/dialogs/security/__snapshots__/ExportE2eKeysDialog-test.tsx.snap test/test-utils/test-utils.ts

# Run tests
bash /workspace/run_script.sh test/components/views/dialogs/security/ExportE2eKeysDialog-test.tsx,test/components/views/dialogs/security/ExportE2eKeysDialog-test.ts,test/test-utils/test-utils.ts,test/components/views/dialogs/security/__snapshots__/ExportE2eKeysDialog-test.tsx.snap > /workspace/stdout.log 2> /workspace/stderr.log

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
