#!/bin/bash
set -x

# ENV exports from Dockerfiles
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60

cd /app

git reset --hard ad9cbe93994888e8f8ba88ce3614dc041a698930
git checkout ad9cbe93994888e8f8ba88ce3614dc041a698930

# Apply user patch
git apply -v /workspace/patch.diff || echo 'WARNING: patch apply failed'

# Apply test setup (mirrors before_repo_set_cmd)
git checkout fe14847bb9bb07cab1b9c6c54335ff22ca5e516a -- test/test-utils/test-utils.ts test/voice-broadcast/components/VoiceBroadcastBody-test.tsx test/voice-broadcast/models/VoiceBroadcastRecording-test.ts test/voice-broadcast/stores/VoiceBroadcastRecordingsStore-test.ts test/voice-broadcast/utils/startNewVoiceBroadcastRecording-test.ts

# Run tests
bash /workspace/run_script.sh test/components/views/dialogs/SpotlightDialog-test.ts,test/voice-broadcast/components/VoiceBroadcastBody-test.tsx,test/components/views/settings/devices/SelectableDeviceTile-test.ts,test/components/structures/TabbedView-test.ts,test/voice-broadcast/utils/startNewVoiceBroadcastRecording-test.ts,test/notifications/ContentRules-test.ts,test/components/views/dialogs/ExportDialog-test.ts,test/test-utils/test-utils.ts,test/voice-broadcast/components/VoiceBroadcastBody-test.ts,test/createRoom-test.ts,test/voice-broadcast/models/VoiceBroadcastRecording-test.ts,test/voice-broadcast/stores/VoiceBroadcastRecordingsStore-test.ts,test/hooks/useDebouncedCallback-test.ts,test/utils/validate/numberInRange-test.ts,test/modules/ModuleComponents-test.ts,test/components/views/settings/Notifications-test.ts > /workspace/stdout.log 2> /workspace/stderr.log

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
