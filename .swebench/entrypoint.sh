#!/bin/bash
set -x

# ENV exports from Dockerfiles
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60

cd /app

git reset --hard 5583d07f25071ceb4f84462150717b68a244f166
git checkout 5583d07f25071ceb4f84462150717b68a244f166

# Apply user patch
git apply -v /workspace/patch.diff || echo 'WARNING: patch apply failed'

# Apply test setup (mirrors before_repo_set_cmd)
git checkout ca58617cee8aa91c93553449bfdf9b3465a5119b -- test/LegacyCallHandler-test.ts

# Run tests
bash /workspace/run_script.sh test/components/views/rooms/NotificationBadge/NotificationBadge-test.ts,test/LegacyCallHandler-test.ts,test/components/views/elements/LabelledCheckbox-test.ts,test/modules/ModuleRunner-test.ts,test/utils/beacon/geolocation-test.ts,test/components/views/context_menus/ContextMenu-test.ts,test/components/views/settings/tabs/room/VoipRoomSettingsTab-test.ts,test/components/views/settings/devices/SecurityRecommendations-test.ts,test/components/views/audio_messages/RecordingPlayback-test.ts,test/components/structures/auth/ForgotPassword-test.ts,test/components/views/spaces/SpacePanel-test.ts,test/components/views/settings/devices/filter-test.ts,test/components/views/rooms/wysiwyg_composer/utils/createMessageContent-test.ts,test/audio/Playback-test.ts > /workspace/stdout.log 2> /workspace/stderr.log

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
