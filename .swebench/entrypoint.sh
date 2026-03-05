#!/bin/bash
set -x

# ENV exports from Dockerfiles
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60

cd /app

git reset --hard 42beccb27e0e5797a10db05bf126e529273d2d95
git checkout 42beccb27e0e5797a10db05bf126e529273d2d95

# Apply user patch
git apply -v /workspace/patch.diff || echo 'WARNING: patch apply failed'

# Apply test setup (mirrors before_repo_set_cmd)
git checkout 0ac7334939981cf85b9591ac295c3816954e287e -- lib/srv/db/access_test.go lib/srv/db/ha_test.go

# Run tests
bash /workspace/run_script.sh TestAccessMySQL/has_access_to_nothing,TestProxyProtocolPostgres,TestAccessPostgres/has_access_to_nothing,TestAuthTokens/correct_Postgres_Cloud_SQL_IAM_auth_token,TestAuthTokens/correct_Postgres_Redshift_IAM_auth_token,TestAccessPostgres,TestAuthTokens/incorrect_MySQL_RDS_IAM_auth_token,TestAccessMySQL/access_allowed_to_specific_user,TestHA,TestAuthTokens/incorrect_Postgres_Redshift_IAM_auth_token,TestAuditMySQL,TestAccessDisabled,TestAccessMySQL,TestAccessMySQL/has_access_to_all_database_users,TestAccessPostgres/access_allowed_to_specific_user/database,TestAuthTokens/incorrect_Postgres_RDS_IAM_auth_token,TestAuthTokens/correct_MySQL_RDS_IAM_auth_token,TestAccessPostgres/no_access_to_users,TestProxyClientDisconnectDueToIdleConnection,TestAuthTokens/incorrect_Postgres_Cloud_SQL_IAM_auth_token,TestDatabaseServerStart,TestProxyClientDisconnectDueToCertExpiration,TestAccessMySQL/access_denied_to_specific_user,TestAccessPostgres/has_access_to_all_database_names_and_users,TestAuthTokens,TestAccessPostgres/no_access_to_databases,TestAuditPostgres,TestAccessPostgres/access_denied_to_specific_user/database,TestProxyProtocolMySQL,TestAuthTokens/correct_Postgres_RDS_IAM_auth_token > /workspace/stdout.log 2> /workspace/stderr.log

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
