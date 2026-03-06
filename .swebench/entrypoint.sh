#!/bin/bash
set -x

# ENV exports from Dockerfiles
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60

cd /app

git reset --hard 53415bfdfeb9f25e6755dde2bc41e9dbca4fa791
git checkout 53415bfdfeb9f25e6755dde2bc41e9dbca4fa791

# Apply user patch
git apply -v /workspace/patch.diff || echo 'WARNING: patch apply failed'

# Apply test setup (mirrors before_repo_set_cmd)
git checkout 53b42e321777a598aaf2bb3eab22d710569f83a8 -- test/components/views/dialogs/spotlight/RoomResultContextMenus-test.tsx test/components/views/rooms/RoomHeader-test.tsx test/components/views/rooms/RoomTile-test.tsx

# Run tests
bash /workspace/run_script.sh test/components/views/settings/tabs/room/SecurityRoomSettingsTab-test.ts,test/components/views/dialogs/spotlight/RoomResultContextMenus-test.tsx,test/utils/ShieldUtils-test.ts,test/components/structures/LoggedInView-test.ts,test/stores/room-list/MessagePreviewStore-test.ts,test/components/views/rooms/RoomHeader-test.ts,test/components/views/settings/tabs/room/VoipRoomSettingsTab-test.ts,test/components/structures/ThreadView-test.ts,test/components/views/dialogs/spotlight/RoomResultContextMenus-test.ts,test/components/views/rooms/RoomHeader-test.tsx,test/components/views/rooms/wysiwyg_composer/SendWysiwygComposer-test.ts,test/components/views/rooms/RoomTile-test.ts,test/components/structures/auth/Registration-test.ts,test/components/views/elements/crypto/VerificationQRCode-test.ts,test/components/views/rooms/RoomTile-test.tsx,test/utils/DateUtils-test.ts,test/components/views/messages/MessageActionBar-test.ts,test/utils/tooltipify-test.ts,test/utils/exportUtils/HTMLExport-test.ts > /workspace/stdout.log 2> /workspace/stderr.log

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
