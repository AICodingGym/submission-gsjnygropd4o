#!/bin/bash
set -x

# ENV exports from Dockerfiles
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60

cd /app

git reset --hard 25a5f278e1116ca22f86d86b4a5259ca05ef2623
git checkout 25a5f278e1116ca22f86d86b4a5259ca05ef2623

# Apply user patch
git apply -v /workspace/patch.diff || echo 'WARNING: patch apply failed'

# Apply test setup (mirrors before_repo_set_cmd)
git checkout 8bd3604dc54b681f1f0f7dd52cbc70b3024184b6 -- internal/server/audit/template/executer_test.go internal/server/audit/template/leveled_logger_test.go internal/server/audit/webhook/client_test.go

# Run tests
bash /workspace/run_script.sh TestExecuter_JSON_Failure,TestExecuter_Execute,TestConstructorWebhookTemplate,TestWebhookClient,TestExecuter_Execute_toJson_valid_Json,TestLeveledLogger,TestConstructorWebhookClient > /workspace/stdout.log 2> /workspace/stderr.log

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
