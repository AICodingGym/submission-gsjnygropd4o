#!/bin/bash
set -x

# ENV exports from Dockerfiles
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60

cd /app

git reset --hard b03433ef8b83a4c82b9d879946fb1ab5afaca522
git checkout b03433ef8b83a4c82b9d879946fb1ab5afaca522

# Apply user patch
git apply -v /workspace/patch.diff || echo 'WARNING: patch apply failed'

# Apply test setup (mirrors before_repo_set_cmd)
git checkout 9a31cd0fa849da810b4fac6c6c015145e850b282 -- test/components/views/settings/JoinRuleSettings-test.tsx

# Run tests
bash /workspace/run_script.sh test/components/views/messages/MessageActionBar-test.ts,test/components/views/settings/EventIndexPanel-test.ts,test/voice-broadcast/stores/VoiceBroadcastPreRecordingStore-test.ts,test/components/views/elements/LabelledCheckbox-test.ts,test/components/views/settings/tabs/user/SessionManagerTab-test.ts,test/components/structures/AutocompleteInput-test.ts,test/components/views/settings/JoinRuleSettings-test.tsx,test/components/views/settings/JoinRuleSettings-test.ts,test/stores/SetupEncryptionStore-test.ts,test/components/views/context_menus/SpaceContextMenu-test.ts > /workspace/stdout.log 2> /workspace/stderr.log

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
