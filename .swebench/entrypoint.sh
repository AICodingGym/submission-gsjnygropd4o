#!/bin/bash
set -x

# ENV exports from Dockerfiles
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60

cd /app

git reset --hard 2d0319ec1b0298fdb0e02afc3109c40cd0cebe65
git checkout 2d0319ec1b0298fdb0e02afc3109c40cd0cebe65

# Apply user patch
git apply -v /workspace/patch.diff || echo 'WARNING: patch apply failed'

# Apply test setup (mirrors before_repo_set_cmd)
git checkout 8f3c8b35153d2227af45f32e46bd1e15bd60b71f -- test/components/views/rooms/__snapshots__/ExtraTile-test.tsx.snap

# Run tests
bash /workspace/run_script.sh test/components/structures/ThreadPanel-test.ts,test/components/structures/LegacyCallEventGrouper-test.ts,test/utils/SessionLock-test.ts,test/components/views/context_menus/EmbeddedPage-test.ts,test/stores/room-list/algorithms/list-ordering/NaturalAlgorithm-test.ts,test/components/views/dialogs/InviteDialog-test.ts,test/components/views/voip/LegacyCallView/LegacyCallViewButtons-test.ts,test/components/views/rooms/ExtraTile-test.ts,test/components/views/rooms/__snapshots__/ExtraTile-test.tsx.snap,test/components/views/rooms/MessageComposer-test.ts,test/components/views/messages/MBeaconBody-test.ts,test/components/views/right_panel/VerificationPanel-test.ts,test/components/views/elements/ProgressBar-test.ts,test/components/views/dialogs/AccessSecretStorageDialog-test.ts,test/components/views/elements/AccessibleButton-test.ts,test/components/views/dialogs/CreateRoomDialog-test.ts,test/components/structures/MatrixChat-test.ts > /workspace/stdout.log 2> /workspace/stderr.log

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
