#!/bin/bash
set -x

# ENV exports from Dockerfiles
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60

cd /app

git reset --hard 64733e59822c91e1d0a72fbe000532fac6f40bf4
git checkout 64733e59822c91e1d0a72fbe000532fac6f40bf4

# Apply user patch
git apply -v /workspace/patch.diff || echo 'WARNING: patch apply failed'

# Apply test setup (mirrors before_repo_set_cmd)
git checkout f3534b42df3dcfe36dc48bddbf14034085af6d30 -- test/TextForEvent-test.ts

# Run tests
bash /workspace/run_script.sh test/stores/BreadcrumbsStore-test.ts,test/components/views/rooms/wysiwyg_composer/utils/autocomplete-test.ts,test/components/views/elements/ReplyChain-test.ts,test/Reply-test.ts,test/utils/notifications-test.ts,test/components/views/elements/PollCreateDialog-test.ts,test/utils/numbers-test.ts,test/components/structures/RoomSearchView-test.ts,test/voice-broadcast/utils/shouldDisplayAsVoiceBroadcastRecordingTile-test.ts,test/components/views/messages/DecryptionFailureBody-test.ts,test/components/views/beacon/RoomCallBanner-test.ts,test/components/views/elements/QRCode-test.ts,test/utils/export-test.ts,test/components/views/rooms/wysiwyg_composer/SendWysiwygComposer-test.ts,test/TextForEvent-test.ts,test/components/views/settings/tabs/user/VoiceUserSettingsTab-test.ts,test/components/structures/ThreadView-test.ts,test/components/structures/auth/Login-test.ts > /workspace/stdout.log 2> /workspace/stderr.log

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
