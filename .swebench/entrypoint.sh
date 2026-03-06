#!/bin/bash
set -x

# ENV exports from Dockerfiles
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60

cd /app

git reset --hard 8b8d24c24c1387210ad1826552126c724c49ee42
git checkout 8b8d24c24c1387210ad1826552126c724c49ee42

# Apply user patch
git apply -v /workspace/patch.diff || echo 'WARNING: patch apply failed'

# Apply test setup (mirrors before_repo_set_cmd)
git checkout 7c63d52500e145d6fff6de41dd717f61ab88d02f -- test/components/views/rooms/wysiwyg_composer/SendWysiwygComposer-test.tsx

# Run tests
bash /workspace/run_script.sh test/components/views/settings/DevicesPanel-test.ts,test/components/views/settings/discovery/EmailAddresses-test.ts,test/SlidingSyncManager-test.ts,test/events/RelationsHelper-test.ts,test/components/views/rooms/wysiwyg_composer/SendWysiwygComposer-test.tsx,test/components/views/settings/devices/DeviceTypeIcon-test.ts,test/components/views/settings/devices/filter-test.ts,test/components/views/settings/shared/SettingsSubsection-test.ts,test/settings/controllers/IncompatibleController-test.ts,test/autocomplete/QueryMatcher-test.ts,test/voice-broadcast/components/molecules/VoiceBroadcastRecordingPip-test.ts,test/editor/diff-test.ts > /workspace/stdout.log 2> /workspace/stderr.log

# Parse results
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json || true

# Print outputs for GHA log
echo '=== STDOUT ==='
cat /workspace/stdout.log 2>/dev/null || true
echo '=== STDERR ==='
cat /workspace/stderr.log 2>/dev/null || true
echo '=== PARSED OUTPUT ==='
cat /workspace/output.json 2>/dev/null || true

# Exit non-zero if any test failed or errored
python -c "
import json, sys
try:
    with open('/workspace/output.json') as f:
        data = json.load(f)
    tests = data.get('tests', [])
    failed = [t for t in tests if t.get('status') in ('FAILED', 'ERROR')]
    if failed:
        print(f'{len(failed)} test(s) FAILED/ERROR')
        sys.exit(1)
    if not tests:
        print('No tests found')
        sys.exit(1)
    print('All tests passed')
except Exception as e:
    print(f'Could not check results: {e}')
    sys.exit(1)
"
