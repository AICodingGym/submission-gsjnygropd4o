#!/bin/bash
set -x

# ENV exports from Dockerfiles
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60

cd /app

git reset --hard c2c0f7761620a8348be46e2f1a3cedca84577eeb
git checkout c2c0f7761620a8348be46e2f1a3cedca84577eeb

# Apply user patch
git apply -v /workspace/patch.diff || echo 'WARNING: patch apply failed'

# Apply test setup (mirrors before_repo_set_cmd)
git checkout b4bb5e13006a729bc0eed8fe6ea18cff54acdacb -- internal/config/config_test.go internal/server/audit/logfile/logfile_test.go

# Run tests
bash /workspace/run_script.sh TestAnalyticsClickhouseConfiguration,TestLogEncoding,TestTracingExporter,TestLoad,TestCacheBackend,TestJSONSchema,TestDatabaseProtocol,TestServeHTTP,Test_mustBindEnv,TestMarshalYAML,TestScheme,TestDefaultDatabaseRoot > /workspace/stdout.log 2> /workspace/stderr.log

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
