#!/bin/bash
set -x

# ENV exports from Dockerfiles
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60

cd /app

git reset --hard 3c6bd20465f0c801ebbcdadaf998e46b37b98e6b
git checkout 3c6bd20465f0c801ebbcdadaf998e46b37b98e6b

# Apply user patch
git apply -v /workspace/patch.diff || echo 'WARNING: patch apply failed'

# Apply test setup (mirrors before_repo_set_cmd)
git checkout 967855b429f749c28c112b8cb1b15bc79157f973 -- internal/server/evaluator_test.go test/api.sh

# Run tests
bash /workspace/run_script.sh TestListFlags_PaginationNextPageToken,TestCacheUnaryInterceptor_UpdateFlag,TestEvaluate_ErrorGettingRules,TestEvaluate_MatchAll_RolloutDistribution,TestEvaluate_FirstRolloutRuleIsZero,TestEvaluate_MatchAny_NoVariants_NoDistributions,TestEvaluate_MatchAny_RolloutDistribution_MultiRule,TestUpdateSegment,TestCacheUnaryInterceptor_UpdateVariant,TestEvaluate_ErrorGettingDistributions,TestUpdateFlag,TestUpdateConstraint,TestEvaluate_FlagNotFound,TestCreateDistribution,TestCacheUnaryInterceptor_DeleteVariant,TestCreateFlag,TestListSegments_PaginationNextPageToken,TestGetRule,TestDeleteVariant,TestEvaluationUnaryInterceptor_BatchEvaluation,TestCreateVariant,TestCacheUnaryInterceptor_CreateVariant,TestEvaluate_MatchAll_SingleVariantDistribution,TestEvaluate_MatchAll_RolloutDistribution_MultiRule,TestEvaluate_MatchAny_RolloutDistribution,TestListRules_PaginationNextPageToken,TestBatchEvaluate,TestDeleteFlag,TestDeleteRule,TestOrderRules,TestErrorUnaryInterceptor,TestValidationUnaryInterceptor,TestCacheUnaryInterceptor_DeleteFlag,TestEvaluate_FlagDisabled,TestCreateSegment,TestEvaluationUnaryInterceptor_Evaluation,TestEvaluate_FlagNoRules,TestEvaluate_RulesOutOfOrder,TestListFlags_PaginationOffset,TestDeleteDistribution,TestGetFlag,TestEvaluate_MatchAll_NoConstraints,TestBatchEvaluate_FlagNotFoundExcluded,TestEvaluate_MatchAny_SingleVariantDistribution,TestUpdateVariant,TestListSegments_PaginationOffset,TestEvaluate_MatchAny_NoConstraints,TestEvaluationUnaryInterceptor_Noop,TestCreateConstraint,Test_matchesNumber,Test_matchesBool,TestCreateRule,TestEvaluate_MatchAll_NoVariants_NoDistributions,Test_matchesString,TestCacheUnaryInterceptor_GetFlag,TestCacheUnaryInterceptor_Evaluate,TestListRules_PaginationOffset,TestUpdateDistribution,TestUpdateRule,TestGetSegment,TestDeleteSegment,TestBatchEvaluate_FlagNotFound,TestDeleteConstraint,TestEvaluate_MultipleZeroRolloutDistributions > /workspace/stdout.log 2> /workspace/stderr.log

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
