#!/bin/bash
set -x

# ENV exports from Dockerfiles
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60

cd /app

git reset --hard 040ec6d3b264d152a674718eb5a0864debb68470
git checkout 040ec6d3b264d152a674718eb5a0864debb68470

# Apply user patch
git apply -v /workspace/patch.diff || echo 'WARNING: patch apply failed'

# Apply test setup (mirrors before_repo_set_cmd)
git checkout 2bb3bbbd8aff1164a2353381cb79e1dc93b90d28 -- lib/backend/dynamo/dynamodbbk_test.go

# Run tests
bash /workspace/run_script.sh TestCreateTable/read/write_capacity_units_are_ignored_if_on_demand_is_on,TestCreateTable/bad_parameter_when_the_incorrect_billing_mode_is_set,TestCreateTable/table_creation_succeeds,TestCreateTable/bad_parameter_when_provisioned_throughput_is_set,TestCreateTable,TestCreateTable/create_table_succeeds > /workspace/stdout.log 2> /workspace/stderr.log

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
