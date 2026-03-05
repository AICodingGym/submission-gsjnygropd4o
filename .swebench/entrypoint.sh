#!/bin/bash
set -x

# ENV exports from Dockerfiles
export DEBIAN_FRONTEND=noninteractive
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60

cd /app

git reset --hard b63f2ef3157bdfb8b3ff46d9097f9e65b00a4c3a
git checkout b63f2ef3157bdfb8b3ff46d9097f9e65b00a4c3a

# Apply user patch
git apply -v /workspace/patch.diff || echo 'WARNING: patch apply failed'

# Apply test setup (mirrors before_repo_set_cmd)
git checkout 8142704f447df6e108d53cab25451c8a94976b92 -- applications/mail/src/app/components/message/extras/ExtraEvents.test.tsx packages/components/containers/calendar/settings/PersonalCalendarsSection.test.tsx packages/shared/test/calendar/subscribe/helpers.spec.ts

# Run tests
bash /workspace/run_script.sh src/app/components/message/extras/ExtraEvents.test.ts,packages/shared/test/calendar/subscribe/helpers.spec.ts,containers/calendar/settings/PersonalCalendarsSection.test.ts,packages/components/containers/calendar/settings/PersonalCalendarsSection.test.tsx,applications/mail/src/app/components/message/extras/ExtraEvents.test.tsx > /workspace/stdout.log 2> /workspace/stderr.log

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
