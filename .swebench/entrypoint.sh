#!/bin/bash
set -x

# ENV exports from Dockerfiles
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60

cd /app

git reset --hard b37b02cd6203f1e32d471acfcec8a7675c0a8664
git checkout b37b02cd6203f1e32d471acfcec8a7675c0a8664

# Apply user patch
git apply -v /workspace/patch.diff || echo 'WARNING: patch apply failed'

# Apply test setup (mirrors before_repo_set_cmd)
git checkout c1b1c6a1541c478d7777a48fca993cc8206c73b9 -- lib/events/auditlog_test.go lib/events/filesessions/fileasync_chaos_test.go lib/events/filesessions/fileasync_test.go

# Run tests
bash /workspace/run_script.sh TestAuditWriter/Session,TestProtoStreamer/5MB_similar_to_S3_min_size_in_bytes,TestProtoStreamer,TestAuditWriter/ResumeMiddle,TestProtoStreamer/no_events,TestProtoStreamer/one_event_using_the_whole_part,TestAuditWriter/ResumeStart,TestAuditLog,TestAuditWriter,TestProtoStreamer/small_load_test_with_some_uneven_numbers,TestProtoStreamer/get_a_part_per_message > /workspace/stdout.log 2> /workspace/stderr.log

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
