#!/bin/bash
set -x

# ENV exports from Dockerfiles
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60

cd /app

git reset --hard 8b933806b52d3785f98d2c397032c8b97a88feb2
git checkout 8b933806b52d3785f98d2c397032c8b97a88feb2

# Apply user patch
git apply -v /workspace/patch.diff || echo 'WARNING: patch apply failed'

# Apply test setup (mirrors before_repo_set_cmd)
git checkout 1be7de788a444f6255e89c10ef6aa608550604a8 -- openlibrary/catalog/add_book/tests/test_match.py openlibrary/catalog/merge/tests/test_merge_marc.py openlibrary/tests/catalog/test_utils.py

# Run tests
bash /workspace/run_script.sh openlibrary/catalog/merge/tests/test_merge_marc.py,openlibrary/tests/catalog/test_utils.py,openlibrary/catalog/add_book/tests/test_match.py > /workspace/stdout.log 2> /workspace/stderr.log

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
