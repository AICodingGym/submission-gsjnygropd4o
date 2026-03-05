#!/bin/bash
set -x

# ENV exports from Dockerfiles
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60

cd /app

git reset --hard 2534098509025989abe9b69bebb6fba6e9c5488b
git checkout 2534098509025989abe9b69bebb6fba6e9c5488b

# Apply user patch
git apply -v /workspace/patch.diff || echo 'WARNING: patch apply failed'

# Apply test setup (mirrors before_repo_set_cmd)
git checkout 9a32a94806b54141b7ff12503c48da680ebcf199 -- gost/debian_test.go models/vulninfos_test.go oval/util_test.go

# Run tests
bash /workspace/run_script.sh TestDebian_Supported/9_is_supported,TestDebian_Supported/empty_string_is_not_supported_yet,TestDebian_Supported/10_is_supported,TestDebian_Supported/11_is_not_supported_yet,TestDebian_Supported/8_is_supported,TestParseCwe,TestSetPackageStates,TestDebian_Supported > /workspace/stdout.log 2> /workspace/stderr.log

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
