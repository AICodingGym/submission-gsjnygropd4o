#!/bin/bash
set -x

# ENV exports from Dockerfiles
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60

cd /app

git reset --hard ad00c6c789bdac9b04403889d7ed426242205d64
git checkout ad00c6c789bdac9b04403889d7ed426242205d64

# Apply user patch
git apply -v /workspace/patch.diff || echo 'WARNING: patch apply failed'

# Apply test setup (mirrors before_repo_set_cmd)
git checkout 82185f232ae8974258397e121b3bc2ed0c3729ed -- tool/tsh/tsh_test.go

# Run tests
bash /workspace/run_script.sh TestFormatConnectCommand/default_user_is_specified,TestReadClusterFlag/TELEPORT_CLUSTER_set,TestOptions/Invalid_key,TestFailedLogin,TestReadClusterFlag/TELEPORT_SITE_and_TELEPORT_CLUSTER_set,_prefer_TELEPORT_CLUSTER,TestKubeConfigUpdate/invalid_selected_cluster,TestOptions/Incomplete_option,TestKubeConfigUpdate/selected_cluster,TestKubeConfigUpdate,TestKubeConfigUpdate/no_tsh_path,TestIdentityRead,TestOptions/Forward_Agent_Yes,TestOptions/Forward_Agent_InvalidValue,TestMakeClient,TestOptions/Equals_Sign_Delimited,TestReadClusterFlag/nothing_set,TestReadClusterFlag/TELEPORT_SITE_and_TELEPORT_CLUSTER_and_CLI_flag_is_set,_prefer_CLI,TestKubeConfigUpdate/no_kube_clusters,TestRelogin,TestOptions,TestKubeConfigUpdate/no_selected_cluster,TestFormatConnectCommand/default_user/database_are_specified,TestFormatConnectCommand/default_database_is_specified,TestFetchDatabaseCreds,TestOptions/Forward_Agent_Local,TestFormatConnectCommand/no_default_user/database_are_specified,TestOptions/AddKeysToAgent_Invalid_Value,TestOptions/Forward_Agent_No,TestOIDCLogin,TestReadClusterFlag,TestFormatConnectCommand/unsupported_database_protocol,TestOptions/Space_Delimited,TestReadClusterFlag/TELEPORT_SITE_set,TestFormatConnectCommand > /workspace/stdout.log 2> /workspace/stderr.log

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
