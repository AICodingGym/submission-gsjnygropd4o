#!/bin/bash
set -x

# ENV exports from Dockerfiles
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60

cd /app

git reset --hard b1e4f1e0324f7e89d1c3c49070a05a243bfddf99
git checkout b1e4f1e0324f7e89d1c3c49070a05a243bfddf99

# Apply user patch
git apply -v /workspace/patch.diff || echo 'WARNING: patch apply failed'

# Apply test setup (mirrors before_repo_set_cmd)
git checkout 326fd1d7be87b03998dbc53bc706fdef90f5065c -- tool/tsh/tsh_test.go

# Run tests
bash /workspace/run_script.sh TestFormatConnectCommand/default_database_is_specified,TestRelogin,TestMakeClient,TestFetchDatabaseCreds,TestKubeConfigUpdate/no_tsh_path,TestOptions/Incomplete_option,TestResolveDefaultAddrSingleCandidate,TestOptions/Forward_Agent_No,TestOptions/Invalid_key,TestReadClusterFlag/TELEPORT_SITE_and_TELEPORT_CLUSTER_and_CLI_flag_is_set,_prefer_CLI,TestOptions/Forward_Agent_Yes,TestOptions/Equals_Sign_Delimited,TestFailedLogin,TestKubeConfigUpdate/invalid_selected_cluster,TestOptions/Forward_Agent_Local,TestKubeConfigUpdate/no_selected_cluster,TestOptions/AddKeysToAgent_Invalid_Value,TestResolveDefaultAddr,TestReadTeleportHome/Environment_not_is_set,TestResolveUndeliveredBodyDoesNotBlockForever,TestResolveDefaultAddrTimeoutBeforeAllRacersLaunched,TestOIDCLogin,TestKubeConfigUpdate,TestResolveNonOKResponseIsAnError,TestResolveDefaultAddrTimeout,TestFormatConnectCommand/default_user/database_are_specified,TestIdentityRead,TestReadClusterFlag/TELEPORT_SITE_and_TELEPORT_CLUSTER_set,_prefer_TELEPORT_CLUSTER,TestOptions,TestKubeConfigUpdate/selected_cluster,TestReadTeleportHome/Environment_is_set,TestOptions/Space_Delimited,TestFormatConnectCommand/unsupported_database_protocol,TestReadClusterFlag/nothing_set,TestReadTeleportHome,TestFormatConnectCommand/default_user_is_specified,TestReadClusterFlag/TELEPORT_CLUSTER_set,TestFormatConnectCommand,TestReadClusterFlag,TestReadClusterFlag/TELEPORT_SITE_set,TestOptions/Forward_Agent_InvalidValue,TestResolveDefaultAddrNoCandidates,TestKubeConfigUpdate/no_kube_clusters,TestFormatConnectCommand/no_default_user/database_are_specified > /workspace/stdout.log 2> /workspace/stderr.log

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
