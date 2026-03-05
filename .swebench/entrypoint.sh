#!/bin/bash
set -x

# ENV exports from Dockerfiles
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60

cd /app

git reset --hard 28f7aac9a5970d27ff3757875b464a5a58a1eb1a
git checkout 28f7aac9a5970d27ff3757875b464a5a58a1eb1a

# Apply user patch
git apply -v /workspace/patch.diff || echo 'WARNING: patch apply failed'

# Apply test setup (mirrors before_repo_set_cmd)
git checkout 494d9de6f0a94ffb491e74744d2735bce02dc0ab -- test/components/structures/RoomView-test.tsx test/stores/RoomViewStore-test.ts

# Run tests
bash /workspace/run_script.sh test/components/views/settings/devices/filter-test.ts,test/components/structures/LoggedInView-test.ts,test/languageHandler-test.ts,test/components/views/settings/devices/SecurityRecommendations-test.ts,test/utils/EventUtils-test.ts,test/events/RelationsHelper-test.ts,test/utils/exportUtils/exportCSS-test.ts,test/components/views/settings/EventIndexPanel-test.ts,test/stores/RoomViewStore-test.ts,test/components/structures/RoomView-test.tsx,test/SlashCommands-test.ts,test/components/views/messages/MStickerBody-test.ts,test/components/views/messages/DateSeparator-test.ts,test/components/views/beacon/LeftPanelLiveShareWarning-test.ts,test/utils/room/canInviteTo-test.ts,test/settings/handlers/RoomDeviceSettingsHandler-test.ts,test/components/views/rooms/RoomPreviewBar-test.ts,test/components/views/settings/CrossSigningPanel-test.ts,test/components/views/beacon/OwnBeaconStatus-test.ts,test/components/views/elements/Pill-test.ts,test/components/views/audio_messages/RecordingPlayback-test.ts,test/components/views/messages/EncryptionEvent-test.ts,test/components/views/elements/ExternalLink-test.ts > /workspace/stdout.log 2> /workspace/stderr.log

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
