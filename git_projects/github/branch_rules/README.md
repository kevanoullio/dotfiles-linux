# GitHub branch rulesets

These files are **exports/records** of the branch rulesets applied to GitHub
repos that use the release workflow in the parent `git_projects/` directory.

## Important

These JSON files are **exported** from the GitHub API (`gh api repos/OWNER/REPO/rulesets`).
They are reference documentation, not inputs. The `source` field contains the repo they were
exported from and must be updated if copied to another repo.

To export your own rulesets: `gh api repos/OWNER/REPO/rulesets --jq '.[]' > protect_main.json`

## Security model

- The **production** branch (`protect_main.json` / "protect_`<prod>`") sets
  `non_fast_forward` ("Block force pushes"). This is the *server-side* guard:
  force-pushes to production are rejected for **everyone**, including you.
  This is real protection — it cannot be bypassed client-side.
- A **fast-forward release push is NOT a force push.** `git release` merges
  locally and runs a normal `git push` of the advanced branch, so the
  `non_fast_forward` rule does not block it. This is exactly why the local
  workflow works despite "Block force pushes" being globally enabled.
- The local `pre-push` hook and the release key (in the `hooks/` folder) only prevent
  *accidental* direct pushes on your machine. They are local-only and can be
  bypassed with `git push --no-verify`. They provide **no** server-side security
  and are not a substitute for the `non_fast_forward` rule.

## Re-applying to a repo

These JSON exports are tied to one repo (note `source` and the hardcoded branch
`refs/heads/main`). To apply the same rules to another repo with its own branch
names, run:

```bash
git_projects/scripts/apply_rules.sh --repo OWNER/NAME
```

This regenerates and upserts the rulesets using the repo's resolved
production and staging branches.
