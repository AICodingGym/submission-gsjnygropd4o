#!/bin/bash
set -x

# ENV exports from Dockerfiles
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60

cd /app

git reset --hard e6fe7b7ea8aad2672854b96b5eb7fb863e19cf92
git checkout e6fe7b7ea8aad2672854b96b5eb7fb863e19cf92

# Apply user patch
git apply -v /workspace/patch.diff || echo 'WARNING: patch apply failed'

# Apply test setup (mirrors before_repo_set_cmd)
git checkout 880428ab94c6ea98d3d18dcaeb17e8767adcb461 -- test/test-utils/test-utils.ts test/toasts/UnverifiedSessionToast-test.tsx test/toasts/__snapshots__/UnverifiedSessionToast-test.tsx.snap

# Run tests
bash /workspace/run_script.sh test/toasts/UnverifiedSessionToast-test.tsx,test/components/structures/MessagePanel-test.ts,test/components/views/rooms/wysiwyg_composer/SendWysiwygComposer-test.ts,test/hooks/useUserOnboardingTasks-test.ts,test/components/views/spaces/SpaceSettingsVisibilityTab-test.ts,test/components/views/dialogs/polls/PollListItemEnded-test.ts,test/toasts/__snapshots__/UnverifiedSessionToast-test.tsx.snap,test/components/views/elements/PowerSelector-test.ts,test/createRoom-test.ts,test/components/views/settings/tabs/user/KeyboardUserSettingsTab-test.ts,test/test-utils/test-utils.ts,test/toasts/UnverifiedSessionToast-test.ts > /workspace/stdout.log 2> /workspace/stderr.log

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
