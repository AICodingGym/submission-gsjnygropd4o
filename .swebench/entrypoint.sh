#!/bin/bash
set -x

# ENV exports from Dockerfiles
export DEBIAN_FRONTEND=noninteractive
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60

cd /app

git reset --hard a1a9b965990811708c7997e783778e146b6b2fbd
git checkout a1a9b965990811708c7997e783778e146b6b2fbd

# Apply user patch
git apply -v /workspace/patch.diff || echo 'WARNING: patch apply failed'

# Apply test setup (mirrors before_repo_set_cmd)
git checkout 4817fe14e1356789c90165c2a53f6a043c2c5f83 -- applications/mail/src/app/helpers/message/messageDraft.test.ts applications/mail/src/app/helpers/message/messageSignature.test.ts applications/mail/src/app/helpers/textToHtml.test.ts

# Run tests
bash /workspace/run_script.sh applications/mail/src/app/helpers/textToHtml.test.ts,src/app/helpers/message/messageSignature.test.ts,applications/mail/src/app/helpers/message/messageSignature.test.ts,applications/mail/src/app/helpers/message/messageDraft.test.ts,src/app/helpers/message/messageDraft.test.ts > /workspace/stdout.log 2> /workspace/stderr.log

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
