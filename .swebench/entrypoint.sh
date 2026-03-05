#!/bin/bash
set -x

# ENV exports from Dockerfiles
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60

cd /app

git reset --hard 0b192c8d132e07e024340a9780c1641a5de5b326
git checkout 0b192c8d132e07e024340a9780c1641a5de5b326

# Apply user patch
git apply -v /workspace/patch.diff || echo 'WARNING: patch apply failed'

# Apply test setup (mirrors before_repo_set_cmd)
git checkout d873ea4fa67d3132eccba39213c1ca2f52064dcc -- lib/client/api_test.go tool/tsh/proxy_test.go

# Run tests
bash /workspace/run_script.sh TestSaveGetTrustedCerts,TestNewInsecureWebClientHTTPProxy,TestLocalKeyAgent_AddDatabaseKey,TestListKeys,TestNewClient_UseKeyPrincipals,TestKeyCRUD,TestKnownHosts,TestEndPlaybackWhilePaused,TestNewClientWithPoolHTTPProxy,TestClientAPI,TestHostCertVerification,TestDefaultHostPromptFunc,TestPruneOldHostKeys,TestMatchesWildcard,TestEmptyPlay,TestNewClientWithPoolNoProxy,TestParseSearchKeywords_SpaceDelimiter,TestMemLocalKeyStore,TestApplyProxySettings,TestConfigDirNotDeleted,TestAddKey_withoutSSHCert,TestParseSearchKeywords,TestWebProxyHostPort,TestProxySSHConfig,TestHostKeyVerification,TestStop,TestPlayPause,TestNewInsecureWebClientNoProxy,TestVirtualPathNames,TestEndPlaybackWhilePlaying,TestDeleteAll,TestLoadKey,TestCheckKey,TestCanPruneOldHostsEntry,TestParseKnownHost,TestPlainHttpFallback,TestIsOldHostsEntry,TestParseProxyHostString,TestAddKey,TestTeleportClient_Login_local > /workspace/stdout.log 2> /workspace/stderr.log

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
