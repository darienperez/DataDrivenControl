# DataDrivenControl

Dissertation research in fully data-driven control.

This repository contains Julia implementations, Pluto notebooks,
and reproducible experiments used to investigate research questions.

## Development

Open this repository's root folder in VS Code.

Start Julia with:

    julia --project=.

Restore the recorded dependencies with:

    using Pkg
    Pkg.instantiate()

Pluto notebooks use the shared project environment at the repository root.

## Repository instruction policy

`AGENTS.md` on `main` is the canonical approved policy. Active research branches
carry the same instructions. Experiment decisions, results, deferred work, and
next steps belong in their existing records under `experiments/`.

### Check before starting or resuming work

From the repository root, run:

```sh
julia --startup-file=no --project=. scripts/check_agents.jl
```

The checker compares the working `AGENTS.md` byte for byte with the copy at
`refs/remotes/origin/main`. It also checks repository instruction files named
`AGENTS.md` or `AGENTS.override.md`, including untracked and ignored overrides,
so a local override cannot silently replace the shared instructions. It prints
the canonical commit and differences. Exit codes are `0` for a match, `1` for
drift, and `2` for an invalid or missing reference, root file, or argument. It
does not fetch, overwrite files, switch branches, or commit anything.

`origin/main` is a local cache. When authorized, `git fetch origin main` refreshes
that cache without changing the working files or publishing anything. Record
the verified commit when reporting live agreement; the checker itself cannot
establish remote freshness. For a pinned reference or another repository, use:

```sh
julia --startup-file=no --project=. scripts/check_agents.jl --canonical-ref <commit-or-ref> --repo <repository-path>
```

To inspect a committed branch copy instead of the working file, add
`--candidate-ref <commit-or-ref>`. Comparing the branch itself matters: a PR's
synthetic merge can inherit newer policy from `main` and hide an old branch copy.

If a check reports drift, inspect it and read the canonical instructions before
implementation. Preserve branch-only preferences for review. Do not replace
user edits or assume that drift authorizes a synchronization operation.

An older branch may lack the checker. After the mechanism has reached `main`,
export its trusted checker to a temporary directory and run it against the
current repository:

```sh
policy_check_dir=$(mktemp -d)
if git show refs/remotes/origin/main:scripts/check_agents.jl > "$policy_check_dir/check_agents.jl"; then
    julia --startup-file=no --project=. "$policy_check_dir/check_agents.jl" --repo .
else
    printf '%s\n' 'Canonical checker unavailable; no check ran.' >&2
    false
fi
```

The export reads Git data and writes only the temporary file. If canonical
`main` does not yet contain the checker, the command reports failure without
running it. Inspect the files with `git diff` and complete the initial rollout.

### Change shared policy

1. Inspect the actual working tree, branch, upstream, and current `main`.
   Propose the scope and validation, then obtain approval under `AGENTS.md`.
2. Prepare an isolated policy change based on current `main`. The policy review
   path permits only `AGENTS.md`, `scripts/check_agents.jl`,
   `test/check_agents.jl`, `.github/workflows/agents-policy.yml`, and `README.md`.
   Keep experiment code and results out of this change.
3. Run the standalone checker tests and whitespace checks:

   ```sh
   julia --startup-file=no --project=. test/check_agents.jl
   git diff --check
   ```

4. When a PR is explicitly authorized, record the policy decisions, checks
   actually run, their outcomes and limits, and remaining rollout work in its
   description. Apply the `agents-policy` label. The repository owner must
   acknowledge the exact proposed commit with a PR comment:

   ```text
   /approve-agents-policy <full-current-head-sha>
   ```

   This is an explicit owner acknowledgement, not a GitHub approving review;
   it also works when the owner authored the PR. A new commit requires a new
   acknowledgement. The exception requires a policy-only diff and current
   `main` as an ancestor. A label alone never bypasses the comparison.
5. After separately authorized integration into `main`, propose updating active
   branches with the approved policy artifacts. A policy-only commit can be
   cherry-picked: this applies that commit's changes without merging the source
   branch's research. Inspect conflicts and local edits before applying it.
   Rerun the comparison and record outstanding branches. Historical branches
   may retain older policy; check them before resuming work.

The shared artifacts are `AGENTS.md`, the checker, its tests, and its workflow.
The CI guard compares all four and the repository's instruction-file inventory;
`README.md` remains editable for ordinary research documentation. Adding a new
scoped instruction file requires an explicitly reviewed expansion of the policy
change scope first. Distribute the mechanism along with the instructions so
branches do not retain an obsolete checker. Existing chats must explicitly
reread the approved policy; new sessions rebuild their instruction context.

### CI and initial rollout

The `AGENTS policy` commit status checks the actual PR head against current
`main`. Its trusted guard job inspects proposed files as Git data and never
executes code from the PR. A separate ordinary `pull_request` job runs the
proposed checker tests with read-only permissions and no supplied secrets.
The reviewed policy path above is the only exception to exact agreement.
Main policy updates also reevaluate open PRs and report remote branch drift.
Branch audit warnings do not rewrite branches or mark historical work complete.

The workflow must first reach `main` before its trusted PR handling is active.
Initial installation therefore needs the local checks and explicit review.
After both the `AGENTS policy` commit status and the `checker-tests` job have
actually been reported on a PR, configure them as required checks for `main`,
with branches required to be up to date before merging. A main audit with no
open PRs does not produce a PR-head policy status. Confirm that Actions policies allow
the guard's `pull_request_target` event; this is a trusted-main job that needs
to publish statuses on PR heads, including forks. GitHub documents the event's
permissions and policy requirements in its
[event security guide](https://docs.github.com/en/actions/reference/security/securely-using-pull_request_target).
Without that repository setting the status reports a result but does not block
integration. Neither this change nor its checker changes repository settings.

Initial rollout checklist:

- [x] Implement and locally verify the mechanism (2026-10-28).
- [x] Prepare the consolidated instruction content for review (2026-10-28).
- [ ] Integrate the isolated policy change into `main` when authorized.
- [ ] Configure the required status check after it has run successfully.
- [ ] Distribute the approved policy artifacts to branches selected for active work.
- [ ] Verify their comparisons and explicitly reread policy in ongoing chats.

Local verification checkpoint, 2026-10-28: the standalone Julia checker suite
passed **108/108 assertions**; the workflow's guard logic passed **26/26 cases**
with mocked GitHub responses. YAML/Python syntax, whitespace, five-file scope,
and preservation of the original instructions were checked. The checker
reproduced the expected differences across all six local branches against
cached `main`; the working policy still reports drift pending consolidation.
GitHub Actions, required-status settings, and the research package tests were
not exercised during this tooling change. These are the earlier mechanism
checks; the consolidation checkpoint below records subsequent work.

Consolidation checkpoint, 2026-10-28: the five policy files are prepared on
`chore/agents-policy` in `/private/tmp/DataDrivenControl-agents-policy`, based
on `main` at `62c2b4a81a98927cdcaa90efec684e69c9bccbf4`. A live read of GitHub's
`main` branch confirmed that base. The consolidated instructions restore the
experiment branch's research lifecycle and Git guidance, make concise task
record upkeep explicit, and retain the drift-prevention rules. Duplicate Julia
and learning instructions were combined. The original Hankel checkout and its
pending mechanism files are preserved. The proposal is uncommitted; content
review, integration, required checks, and distribution remain open.

Validation rerun in the isolated policy worktree: `julia --startup-file=no
--project=. test/check_agents.jl` passed **108/108 assertions**;
`python3 /private/tmp/ddc_agents_policy_ci_fixtures.py` passed **26/26 mocked
guard cases**. YAML/embedded Python syntax, permission boundaries, all five
files' whitespace, and `git diff --check` passed. Scope checks confirmed only
the five policy files differ from `main`, with the three mechanism files
unchanged from the earlier implementation. A preservation snapshot confirmed
all 20 original checkout files, its status, branch, and HEAD are unchanged.
Independent review found no lost workflow preferences or blocking conflicts.
The checker returned **1 (expected drift)** against canonical `62c2b4a`: this
is an unmerged policy proposal, not a synchronized branch. Research package
tests, notebook execution, and live GitHub Actions were not rerun. Next: review
the consolidated `AGENTS.md`, then authorize a policy-only commit and PR when ready.

Publication preparation, 2026-10-28: the user's continuation authorizes the
policy-only checkpoint and draft PR. Live GitHub verification still places
`main` at `62c2b4a81a98927cdcaa90efec684e69c9bccbf4`; no existing policy PR was
found. Final scope, protected-file, whitespace, and original-checkout checks
are recorded with the PR validation results. The local regression results above
are earlier executed checks, not new runs for publication. The draft PR will
record the actual commit, remote publication, and live CI outcomes. Integration,
required-status settings, and distribution to research branches remain open.
