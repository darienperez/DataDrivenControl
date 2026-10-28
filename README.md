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

Rollout checkpoint — 2026-10-28:

- [x] Consolidate the workflow instructions and merge [PR #2](https://github.com/darienperez/DataDrivenControl/pull/2) into `main` at `e74906b`.
- [x] Commit and publish the synchronized policy on the Hankel branch.
- [x] Synchronize every existing published branch and advance the local-only `status` pointer.
- [x] Verify instruction agreement and preserve all nonpolicy branch contents.
- [ ] Verify the `AGENTS policy` status on this rollout-record PR.
- [ ] Enable and verify required checks on `main`.

The policy rollout commits contain only `AGENTS.md`, `README.md`, the checker,
its tests, and its workflow. Every other tree entry and the earlier branch
history were preserved. The historical foundation branch received an appended
policy commit; it was not reset or merged with research work.

| Branch | Policy checkpoint | Nonpolicy files preserved |
| --- | --- | ---: |
| `foundation/f1-hankel-matrices` | `1c92310` | 15 |
| `foundation/f1-benchmark` | `8340738` | 10 |
| `experiment/001-data-informativity` | `f4de385` | 10 |
| `chore/project-foundation` | `20ee154` | 7 |
| `chore/agents-policy` | `523cc1b` (already matched) | Unchanged |
| `status` | `e74906b` (local fast-forward only) | Unchanged |

No remote `status` branch was created. A policy-only update does not settle an
unfinished research question or make the research branch ready to merge.

The repository owner changed its visibility to public after GitHub rejected
private-repository branch protection under the current account plan. Existing
rulesets were empty and `main` had no branch protection. An active Actions event
policy now permits the five existing triggers only for
`.github/workflows/agents-policy.yml`; other workflows are outside this rule.
The intended required checks are `AGENTS policy`, `checker-tests`, and package
`test`, with an up-to-date base, PRs required, and administrator enforcement.
No additional reviewer is required for this solo-owner workflow.

Validation already executed:

- Local checker suite: **108/108 assertions**; mocked guard cases: **26/26**.
- Initial PR and post-merge Linux checker suites: **108/108 assertions** each.
- Initial PR package CI: **1/1 smoke assertion**, with both manifest checks passing; main package CI also passed.
- Per-branch policy comparisons and staged whitespace checks: passed.
- Each synchronization commit has its old head as sole parent, exactly five changed paths, canonical policy modes/blobs, and identical nonpolicy tree entries.
- The post-merge trusted audit ran successfully and reported the expected earlier drift; the PR-head status is a separate verification below.

The package environment emitted headless OpenGL/GLFW initialization messages
during precompilation despite successful job exits. No dependency, reference,
tolerance, metric, or research code was changed for this rollout. The earlier
local and CI results above were not rerun for this documentation edit.

This PR records the live gate result and protection settings once verified.
The original implementation and intermediate validation checkpoints remain in
[PR #2](https://github.com/darienperez/DataDrivenControl/pull/2).
