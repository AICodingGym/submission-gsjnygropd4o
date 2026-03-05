#!/bin/bash
set -x

# ENV exports from Dockerfiles
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60

cd /app

git reset --hard 2d369d0cfe61ca06294b186eecb348104e9c98ae
git checkout 2d369d0cfe61ca06294b186eecb348104e9c98ae

# Apply user patch
git apply -v /workspace/patch.diff || echo 'WARNING: patch apply failed'

# Apply test setup (mirrors before_repo_set_cmd)
git checkout 17ae386d1e185ba742eea4668ca77642e22b54c4 -- oval/util_test.go

# Run tests
bash /workspace/run_script.sh TestIsOvalDefAffected,Test_lessThan/only_ovalmodels.Package_has_underscoreMinorversion.,Test_ovalResult_Sort/already_sorted,TestPackNamesOfUpdate,Test_ovalResult_Sort,Test_lessThan/neither_newVer_nor_ovalmodels.Package_have_underscoreMinorversion.,Test_lessThan,Test_ovalResult_Sort/sort,TestParseCvss3,Test_centOSVersionToRHEL/noop,TestPackNamesOfUpdateDebian,Test_lessThan/newVer_and_ovalmodels.Package_both_have_underscoreMinorversion.,Test_centOSVersionToRHEL,TestUpsert,TestDefpacksToPackStatuses,Test_lessThan/only_newVer_has_underscoreMinorversion.,TestParseCvss2,Test_centOSVersionToRHEL/remove_centos.,Test_centOSVersionToRHEL/remove_minor > /workspace/stdout.log 2> /workspace/stderr.log

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
