#!/usr/bin/env bash
#
# Test runner for the git_projects security/workflow test suite.
#
# Discovers every `*.test.sh` under tests/git_projects/, executes each in its
# own subprocess (so environment/state never leaks between files), and reports
# a pass/fail summary. A non-zero exit code means one or more test files failed.
#
# Usage:
#   tests/run.sh                # run the whole suite
#   tests/run.sh hooks          # only files whose path contains "hooks"
#   tests/run.sh alias          # only files whose path contains "alias"
#
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
export TESTS_HOME="$ROOT"

pattern="${1:-}"

count=0
failed=0
while IFS= read -r -d '' t; do
	if [ -n "$pattern" ] && [[ "$t" != *"$pattern"* ]]; then
		continue
	fi
	count=$((count + 1))
	printf '\nRUN  %s\n' "${t#"$ROOT"/}"
	if (
		BASH_ENV= bash "$t"
	); then
		printf 'PASS %s\n' "${t#"$ROOT"/}"
	else
		printf 'FAIL %s\n' "${t#"$ROOT"/}"
		failed=1
	fi
done < <(find "$ROOT/git_projects" -name '*.test.sh' -print0 | sort -z)

printf '\n== %d test file(s) run ==\n' "$count"
if [ "$failed" -ne 0 ]; then
	echo "RESULT: FAIL"
	exit 1
fi
echo "RESULT: PASS"
