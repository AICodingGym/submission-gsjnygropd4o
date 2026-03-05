#!/bin/bash
set -x

# ENV exports from Dockerfiles
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60

cd /app

git reset --hard 7b8bfe4f609a40c5a4d592b91c91d2921ed24e64
git checkout 7b8bfe4f609a40c5a4d592b91c91d2921ed24e64

# Apply user patch
git apply -v /workspace/patch.diff || echo 'WARNING: patch apply failed'

# Apply test setup (mirrors before_repo_set_cmd)
git checkout ac2fb2f9b4fd1896b554d3011df23d3d71295779 -- lib/events/emitter_test.go

# Run tests
bash /workspace/run_script.sh TestWriterEmitter,TestAuditWriter/ResumeStart,TestProtoStreamer/small_load_test_with_some_uneven_numbers,TestAuditWriter/ResumeMiddle,TestProtoStreamer/no_events,TestProtoStreamer,TestAuditLog,TestProtoStreamer/5MB_similar_to_S3_min_size_in_bytes,TestAuditWriter/Session,TestProtoStreamer/one_event_using_the_whole_part,TestProtoStreamer/get_a_part_per_message,TestAuditWriter > /workspace/stdout.log 2> /workspace/stderr.log

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
