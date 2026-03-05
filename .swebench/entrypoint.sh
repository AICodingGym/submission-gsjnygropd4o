#!/bin/bash
set -x

# ENV exports from Dockerfiles
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60

cd /app

git reset --hard 85bb23a3571794c7ba01e61904bac6913c3d9729
git checkout 85bb23a3571794c7ba01e61904bac6913c3d9729

# Apply user patch
git apply -v /workspace/patch.diff || echo 'WARNING: patch apply failed'

# Apply test setup (mirrors before_repo_set_cmd)
git checkout 02e21636c58e86c51119b63e0fb5ca7b813b07b1 -- .github/workflows/integration-test.yml internal/cache/redis/client_test.go internal/config/config_test.go

# Run tests
bash /workspace/run_script.sh TestLogEncoding,TestCacheBackend,TestDefaultDatabaseRoot,TestScheme,TestTracingExporter,Test_mustBindEnv,TestAnalyticsClickhouseConfiguration,TestServeHTTP,TestTLSCABundle,TestLoad,TestMarshalYAML,TestGetConfigFile,TestStructTags,TestJSONSchema,TestTLSInsecure,TestDatabaseProtocol > /workspace/stdout.log 2> /workspace/stderr.log

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
