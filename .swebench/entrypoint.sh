#!/bin/bash
set -x

# ENV exports from Dockerfiles
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60

cd /app

git reset --hard fe3f1b99245266e848f7b8f240f1f81ae3ff04df
git checkout fe3f1b99245266e848f7b8f240f1f81ae3ff04df

# Apply user patch
git apply -v /workspace/patch.diff || echo 'WARNING: patch apply failed'

# Apply test setup (mirrors before_repo_set_cmd)
git checkout 9aa0d87a21bede91c2b45c32187456bb69455e92 -- config/tomlloader_test.go

# Run tests
bash /workspace/run_script.sh TestMajorVersion,TestIsValidImage/no_image_name_with_digest,TestToCpeURI,TestIsValidImage/ok_with_tag,TestIsValidImage,TestIsValidImage/no_tag_and_digest,TestSyslogConfValidate,TestIsValidImage/no_image_name_with_tag,TestIsValidImage/ok_with_digest > /workspace/stdout.log 2> /workspace/stderr.log

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
