#!/bin/bash
set -x

# ENV exports from Dockerfiles
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60

cd /app

git reset --hard 962f8d028e1a2e1dd8a87035d7d8d85eb6665eaf
git checkout 962f8d028e1a2e1dd8a87035d7d8d85eb6665eaf

# Apply user patch
git apply -v /workspace/patch.diff || echo 'WARNING: patch apply failed'

# Apply test setup (mirrors before_repo_set_cmd)
git checkout cf06f4ebfab7fa21eed3e5838592e8e44566957f -- server/evaluator_test.go

# Run tests
bash /workspace/run_script.sh TestEvaluate_FlagNoRules,TestEvaluate_FlagNotFound,TestBatchEvaluate_FlagNotFound,TestEvaluate_MatchAll_NoVariants_NoDistributions,TestEvaluate_MatchAll_RolloutDistribution,TestEvaluate_MatchAll_RolloutDistribution_MultiRule,TestEvaluate_MatchAny_NoVariants_NoDistributions,TestEvaluate_MatchAny_SingleVariantDistribution,Test_matchesBool,TestValidationUnaryInterceptor,TestEvaluate_MatchAll_NoConstraints,TestBatchEvaluate,TestEvaluate_RulesOutOfOrder,Test_matchesString,TestEvaluate_MatchAny_NoConstraints,TestEvaluate_MatchAny_RolloutDistribution_MultiRule,TestEvaluate_MatchAny_RolloutDistribution,TestEvaluate_FirstRolloutRuleIsZero,TestErrorUnaryInterceptor,TestEvaluate_MultipleZeroRolloutDistributions,Test_matchesNumber,TestEvaluate_FlagDisabled,TestEvaluate_MatchAll_SingleVariantDistribution,TestBatchEvaluate_FlagNotFoundExcluded > /workspace/stdout.log 2> /workspace/stderr.log

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
