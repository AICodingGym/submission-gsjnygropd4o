#!/bin/bash
set -x

# ENV exports from Dockerfiles
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60

cd /app

git reset --hard 1d550f0c0d693844b6f4b44fd7859254ef3569c0
git checkout 1d550f0c0d693844b6f4b44fd7859254ef3569c0

# Apply user patch
git apply -v /workspace/patch.diff || echo 'WARNING: patch apply failed'

# Apply test setup (mirrors before_repo_set_cmd)
git checkout aebaecd026f752b187f11328b0d464761b15d2ab -- internal/storage/fs/cache_test.go

# Run tests
bash /workspace/run_script.sh TestCountFlags,TestListRollouts,TestFS_Empty_Features_File,TestListSegments,TestCountSegments,TestSnapshotFromFS_Invalid,TestListRules,TestGetVersion,TestParseFliptIndexParsingError,Test_SnapshotCache_Delete,TestFSWithoutIndex,TestCountNamespaces,TestFSWithIndex,TestWalkDocuments,TestCountRollouts,Test_SnapshotCache_Concurrently,TestListNamespaces,TestCountRules,Test_SnapshotCache,TestParseFliptIndex,TestFS_YAML_Stream > /workspace/stdout.log 2> /workspace/stderr.log

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
