#!/bin/bash
set -x

# ENV exports from Dockerfiles
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60

cd /app

git reset --hard 973513cc758030917cb339ba35d6436bc2c7d5dd
git checkout 973513cc758030917cb339ba35d6436bc2c7d5dd

# Apply user patch
git apply -v /workspace/patch.diff || echo 'WARNING: patch apply failed'

# Apply test setup (mirrors before_repo_set_cmd)
git checkout cf3c899dd1f221aa1a1f4c5a80dffc05b9c21c85 -- test/voice-broadcast/components/atoms/LiveBadge-test.tsx test/voice-broadcast/components/atoms/VoiceBroadcastHeader-test.tsx test/voice-broadcast/components/atoms/__snapshots__/LiveBadge-test.tsx.snap test/voice-broadcast/components/atoms/__snapshots__/VoiceBroadcastHeader-test.tsx.snap test/voice-broadcast/components/molecules/VoiceBroadcastPlaybackBody-test.tsx test/voice-broadcast/components/molecules/VoiceBroadcastRecordingBody-test.tsx test/voice-broadcast/components/molecules/__snapshots__/VoiceBroadcastPlaybackBody-test.tsx.snap test/voice-broadcast/components/molecules/__snapshots__/VoiceBroadcastRecordingBody-test.tsx.snap test/voice-broadcast/components/molecules/__snapshots__/VoiceBroadcastRecordingPip-test.tsx.snap test/voice-broadcast/models/VoiceBroadcastPlayback-test.ts

# Run tests
bash /workspace/run_script.sh test/utils/device/clientInformation-test.ts,test/components/views/elements/ProgressBar-test.ts,test/voice-broadcast/components/molecules/VoiceBroadcastRecordingBody-test.tsx,test/voice-broadcast/components/molecules/VoiceBroadcastRecordingPip-test.ts,test/voice-broadcast/components/atoms/VoiceBroadcastHeader-test.tsx,test/voice-broadcast/components/molecules/VoiceBroadcastRecordingBody-test.ts,test/voice-broadcast/components/atoms/VoiceBroadcastHeader-test.ts,test/voice-broadcast/components/atoms/LiveBadge-test.tsx,test/voice-broadcast/components/atoms/__snapshots__/VoiceBroadcastHeader-test.tsx.snap,test/voice-broadcast/components/atoms/__snapshots__/LiveBadge-test.tsx.snap,test/voice-broadcast/components/atoms/LiveBadge-test.ts,test/voice-broadcast/components/molecules/VoiceBroadcastPlaybackBody-test.tsx,test/voice-broadcast/components/molecules/__snapshots__/VoiceBroadcastPlaybackBody-test.tsx.snap,test/audio/Playback-test.ts,test/voice-broadcast/models/VoiceBroadcastPlayback-test.ts,test/voice-broadcast/components/molecules/VoiceBroadcastPlaybackBody-test.ts,test/voice-broadcast/components/molecules/__snapshots__/VoiceBroadcastRecordingBody-test.tsx.snap,test/utils/local-room-test.ts,test/components/views/dialogs/ForwardDialog-test.ts,test/voice-broadcast/components/molecules/__snapshots__/VoiceBroadcastRecordingPip-test.tsx.snap,test/events/forward/getForwardableEvent-test.ts,test/utils/dm/createDmLocalRoom-test.ts > /workspace/stdout.log 2> /workspace/stderr.log

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
