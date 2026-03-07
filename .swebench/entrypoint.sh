#!/bin/bash
set -x

# ENV exports from Dockerfiles
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60

cd /app

git reset --hard 19b81d257f7b8b134bf5d7e555c9d5fca3570f69
git checkout 19b81d257f7b8b134bf5d7e555c9d5fca3570f69

# Apply user patch
git apply -v /workspace/patch.diff || echo 'WARNING: patch apply failed'

# Apply test setup (mirrors before_repo_set_cmd)
git checkout 923ad4323b2006b2b180544429455ffe7d4a6cc3 -- test/components/views/right_panel/RoomSummaryCard-test.tsx test/components/views/right_panel/__snapshots__/RoomSummaryCard-test.tsx.snap

# Run tests
bash /workspace/run_script.sh test/components/views/right_panel/RoomSummaryCard-test.tsx,test/components/views/elements/Linkify-test.ts,test/components/views/voip/CallView-test.ts,test/components/views/right_panel/RoomHeaderButtons-test.ts,test/components/views/elements/ExternalLink-test.ts,test/components/views/right_panel/RoomSummaryCard-test.ts,test/components/views/right_panel/__snapshots__/RoomSummaryCard-test.tsx.snap,test/components/structures/ThreadPanel-test.ts,test/voice-broadcast/utils/textForVoiceBroadcastStoppedEventWithoutLink-test.ts,test/settings/watchers/ThemeWatcher-test.ts > /workspace/stdout.log 2> /workspace/stderr.log

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
