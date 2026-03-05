#!/bin/bash
set -x

# ENV exports from Dockerfiles
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60

cd /app

git reset --hard 2f8e98242c6de16cbfb6ebb6bc29cfe404b343cb
git checkout 2f8e98242c6de16cbfb6ebb6bc29cfe404b343cb

# Apply user patch
git apply -v /workspace/patch.diff || echo 'WARNING: patch apply failed'

# Apply test setup (mirrors before_repo_set_cmd)
git checkout d06cf09bf0b3d4a0fbe6bd32e4115caea2083168 -- test/test-utils/utilities.ts test/unit-tests/components/views/messages/MPollBody-test.tsx test/unit-tests/components/views/settings/JoinRuleSettings-test.tsx test/unit-tests/components/views/settings/SecureBackupPanel-test.tsx test/unit-tests/utils/pillify-test.tsx test/unit-tests/utils/tooltipify-test.tsx

# Run tests
bash /workspace/run_script.sh test/unit-tests/vector/platform/WebPlatform-test.ts,test/unit-tests/hooks/useUserDirectory-test.ts,test/unit-tests/utils/UrlUtils-test.ts,test/test-utils/utilities.ts,test/unit-tests/components/views/settings/SecureBackupPanel-test.tsx,test/unit-tests/utils/tooltipify-test.ts,test/unit-tests/utils/pillify-test.tsx,test/unit-tests/components/views/messages/MPollBody-test.tsx,test/unit-tests/components/views/location/LocationPicker-test.ts,test/unit-tests/components/views/polls/pollHistory/PollHistory-test.ts,test/unit-tests/settings/handlers/RoomDeviceSettingsHandler-test.ts,test/CreateCrossSigning-test.ts,test/unit-tests/editor/caret-test.ts,test/unit-tests/components/views/settings/JoinRuleSettings-test.tsx,test/unit-tests/components/views/context_menus/RoomGeneralContextMenu-test.ts,test/unit-tests/utils/tooltipify-test.tsx,test/unit-tests/voice-broadcast/utils/hasRoomLiveVoiceBroadcast-test.ts,test/unit-tests/components/views/toasts/VerificationRequestToast-test.ts,test/unit-tests/utils/pillify-test.ts > /workspace/stdout.log 2> /workspace/stderr.log

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
