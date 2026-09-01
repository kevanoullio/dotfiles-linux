#!/bin/bash
#
# apply_rules.sh — apply the release-workflow branch rulesets to a GitHub repo.
#
# Generates and upserts two branch rulesets (protect_{prod} / protect_{staging})
# using per-repo branch names, so different repos can use different branch
# naming with zero manual JSON editing. The rules mirror the exported rules in
# github/branch_rules/.
#
# Branch names are resolved exactly like `git release` and the pre-push hook
# (env -> git config -> default), via the release-common.sh library file.
# By default it looks at ~/.config/git/hooks/release-common.sh; override with
# --libdir or the RELEASE_LIBDIR environment variable.
#
# Prerequisites:
#   - GitHub CLI (gh) installed and authenticated.
#   - For per-repo branch resolution, run inside a clone of the target repo;
#     otherwise pass --repo and rely on env vars / global config.
#
# NOTE: integration_id defaults to 0. You MUST set it for your repo:
#   apply_rules.sh --repo OWNER/REPO --integration-id 15368
#
# Usage:
#   apply_rules.sh [--repo OWNER/NAME] [--prod NAME] [--staging NAME] [--libdir DIR] [--integration-id ID]

set -euo pipefail

LIBDIR="${RELEASE_LIBDIR:-$HOME/.config/git/hooks}"
INTEGRATION_ID="0"

REPO=""
PROD_OVERRIDE=""
STAGING_OVERRIDE=""

usage() {
	cat <<'EOF'
Usage: apply_rules.sh [--repo OWNER/NAME] [--prod NAME] [--staging NAME] [--libdir DIR] [--integration-id ID]

  --repo OWNER/NAME      Target repo (default: derived from origin remote)
  --prod NAME            Production branch (default: release_branch prod = main)
  --staging NAME         Staging branch   (default: release_branch staging = staging)
  --libdir DIR           Path to directory containing release-common.sh
                         (default: ~/.config/git/hooks)
  --integration-id ID    GitHub Actions integration ID (default: 0 — must be set for your repo)
                         Find it via: gh api repos/OWNER/REPO/actions/runs --jq '.workflow_runs[0].head_repository.id'
EOF
}

while [ "$#" -gt 0 ]; do
	case "$1" in
		--repo) REPO="$2"; shift 2 ;;
		--prod) PROD_OVERRIDE="$2"; shift 2 ;;
		--staging) STAGING_OVERRIDE="$2"; shift 2 ;;
		--libdir) LIBDIR="$2"; shift 2 ;;
		--integration-id) INTEGRATION_ID="$2"; shift 2 ;;
		-h|--help) usage; exit 0 ;;
		*) echo "Unknown option: $1" >&2; usage; exit 1 ;;
	esac
done

# Source the shared library (resolves branch names and the release key).
_libfile="$LIBDIR/release-common.sh"
if [ ! -f "$_libfile" ]; then
	echo "Error: release-common.sh not found at $_libfile." >&2
	echo "Pass --libdir or set RELEASE_LIBDIR to the directory containing it." >&2
	exit 1
fi
. "$_libfile"

if [ -z "$REPO" ]; then
	REMOTE=$(git config --get remote.origin.url || true)
	REPO=$(printf '%s\n' "$REMOTE" \
		| sed -E 's#(git@|https?://)[^:/]+[:/]##; s#\.git$##')
fi
if [ -z "$REPO" ]; then
	echo "Error: cannot determine repo. Pass --repo OWNER/NAME." >&2
	exit 1
fi

PROD="${PROD_OVERRIDE:-$(release_branch prod)}"
STAGING="${STAGING_OVERRIDE:-$(release_branch staging)}"

echo "Applying branch rulesets to $REPO"
echo "  production -> $PROD"
echo "  staging    -> $STAGING"

if ! command -v gh >/dev/null 2>&1; then
	echo "Error: 'gh' CLI is required." >&2
	exit 1
fi

# Common status-check block for staging.
STATUS_CHECKS='{"strict_required_status_checks_policy":false,"do_not_enforce_on_create":false,"required_status_checks":[{"context":"Build","integration_id":'"$INTEGRATION_ID"'},{"context":"Unit Tests","integration_id":'"$INTEGRATION_ID"'},{"context":"Integration Tests","integration_id":'"$INTEGRATION_ID"'},{"context":"E2E Tests","integration_id":'"$INTEGRATION_ID"'}]}'

# Build a ruleset payload for a given branch name and a jq rules array.
build_ruleset() {
	local branch="$1" rules_json="$2"
	jq -n \
		--arg name "protect_${branch}" \
		--arg ref "refs/heads/${branch}" \
		--argjson rules "$rules_json" \
		'{ name: $name, target: "branch", enforcement: "active",
		   conditions: { ref_name: { include: [$ref], exclude: [] } },
		   rules: $rules, bypass_actors: [] }'
}

# Resolve an existing ruleset id by name, or print nothing.
ruleset_id() {
	gh api "repos/$REPO/rulesets" \
		--jq ".[] | select(.name == \"protect_$1\") | .id" 2>/dev/null | head -n1
}

upsert_ruleset() {
	local name="$1" payload id endpoint method
	payload="$2"
	id=$(ruleset_id "$name")
	if [ -n "$id" ]; then
		endpoint="repos/$REPO/rulesets/$id"
		method=PUT
		echo "  updating ruleset '$name' (id $id)..."
	else
		endpoint="repos/$REPO/rulesets"
		method=POST
		echo "  creating ruleset '$name'..."
	fi
	gh api --method "$method" "$endpoint" --input - <<<"$payload" >/dev/null
}

# Production: block force pushes (non_fast_forward) + block deletion + code
# quality. Fast-forward pushes by an authorized user remain allowed; force
# pushes are rejected for everyone.
PROD_RULES='[
  {"type":"non_fast_forward"},
  {"type":"deletion"},
  {"type":"code_quality","parameters":{"severity":"errors"}}
]'

# Staging: require a pull request (squash), status checks, block force pushes.
STAGING_RULES="[
  {\"type\":\"deletion\"},
  {\"type\":\"pull_request\",\"parameters\":{\"required_approving_review_count\":0,\"dismiss_stale_reviews_on_push\":false,\"required_reviewers\":[],\"require_code_owner_review\":true,\"require_last_push_approval\":false,\"required_review_thread_resolution\":false,\"allowed_merge_methods\":[\"squash\"]}},
  {\"type\":\"code_quality\",\"parameters\":{\"severity\":\"errors\"}},
  {\"type\":\"required_status_checks\",\"parameters\":$STATUS_CHECKS},
  {\"type\":\"non_fast_forward\"}
]"

upsert_ruleset "${PROD}"    "$(build_ruleset "$PROD"    "$PROD_RULES")"
upsert_ruleset "${STAGING}" "$(build_ruleset "$STAGING" "$STAGING_RULES")"

echo "Done."
