#!/bin/bash
set -x

# ENV exports from Dockerfiles
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60

cd /app

git reset --hard 07e7b69c04116f598ed2376616cbb46343d9a0e9
git checkout 07e7b69c04116f598ed2376616cbb46343d9a0e9

# Apply user patch
git apply -v /workspace/patch.diff || echo 'WARNING: patch apply failed'

# Apply test setup (mirrors before_repo_set_cmd)
git checkout eea46a0d1b99a6dadedbb6a3502d599235fa7ec3 -- test/units/modules/network/eric_eccli/__init__.py test/units/modules/network/eric_eccli/eccli_module.py test/units/modules/network/eric_eccli/fixtures/configure_terminal test/units/modules/network/eric_eccli/fixtures/show_version test/units/modules/network/eric_eccli/test_eccli_command.py

# Run tests
bash /workspace/run_script.sh test/units/modules/network/eric_eccli/test_eccli_command.py,test/units/modules/network/eric_eccli/__init__.py,test/units/modules/network/eric_eccli/eccli_module.py > /workspace/stdout.log 2> /workspace/stderr.log

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
