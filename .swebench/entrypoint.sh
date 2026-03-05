#!/bin/bash
set -x

# ENV exports from Dockerfiles
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60

cd /app

git reset --hard 68f03d01672a868f86e0fd73dde3957df8bf0dab
git checkout 68f03d01672a868f86e0fd73dde3957df8bf0dab

# Apply user patch
git apply -v /workspace/patch.diff || echo 'WARNING: patch apply failed'

# Apply test setup (mirrors before_repo_set_cmd)
git checkout 55bff343cdaad1f04496f724eda4b55d422d7f17 -- persistence/album_repository_test.go persistence/artist_repository_test.go persistence/genre_repository_test.go persistence/mediafile_repository_test.go persistence/persistence_suite_test.go persistence/playlist_repository_test.go persistence/playqueue_repository_test.go persistence/property_repository_test.go persistence/radio_repository_test.go persistence/sql_bookmarks_test.go persistence/user_repository_test.go

# Run tests
bash /workspace/run_script.sh TestPersistence > /workspace/stdout.log 2> /workspace/stderr.log

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
