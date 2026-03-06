#!/bin/bash
set -x

# ENV exports from Dockerfiles
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60

cd /app

git reset --hard f34c1609c3c42f095b59bc068620f342894f94ed
git checkout f34c1609c3c42f095b59bc068620f342894f94ed

# Apply user patch
git apply -v /workspace/patch.diff || echo 'WARNING: patch apply failed'

# Apply test setup (mirrors before_repo_set_cmd)
git checkout ecfd1736e5dd9808e87911fc264e6c816653e1a9 -- test/components/structures/RoomSearchView-test.tsx test/components/views/rooms/SearchResultTile-test.tsx

# Run tests
bash /workspace/run_script.sh test/components/views/rooms/SearchResultTile-test.ts,test/utils/sets-test.ts,test/components/structures/RoomSearchView-test.tsx,test/components/structures/RoomSearchView-test.ts,test/utils/direct-messages-test.ts,test/components/views/settings/devices/DeviceExpandDetailsButton-test.ts,test/components/views/context_menus/ThreadListContextMenu-test.ts,test/components/views/rooms/SearchResultTile-test.tsx > /workspace/stdout.log 2> /workspace/stderr.log

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
