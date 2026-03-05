#!/bin/bash
set -x

# ENV exports from Dockerfiles
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60

cd /app

git reset --hard 168f61194a4cd0f515a589511183bb1bd4f87507
git checkout 168f61194a4cd0f515a589511183bb1bd4f87507

# Apply user patch
git apply -v /workspace/patch.diff || echo 'WARNING: patch apply failed'

# Apply test setup (mirrors before_repo_set_cmd)
git checkout 2ca5dfb3513e4e786d2b037075617cccc286d5c3 -- internal/config/config_test.go internal/metrics/metrics_test.go internal/tracing/tracing_test.go

# Run tests
bash /workspace/run_script.sh TestLoad,Test_mustBindEnv,TestCacheBackend,TestScheme,TestDatabaseProtocol,TestMarshalYAML,TestGetxporter,TestLogEncoding,TestDefaultDatabaseRoot,TestGetConfigFile,TestTracingExporter,TestServeHTTP,TestAnalyticsClickhouseConfiguration,TestJSONSchema > /workspace/stdout.log 2> /workspace/stderr.log

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
