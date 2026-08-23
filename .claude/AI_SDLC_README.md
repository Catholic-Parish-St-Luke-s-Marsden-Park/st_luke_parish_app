# AI Vibe Coding SDLC for Claude Code

This repository uses a Claude Code-specific, agent-driven SDLC for structured feature delivery of the St Luke's Parish Marsden Park mobile app.

## Purpose

This workflow exists to make AI-assisted development:
- auditable
- maintainable
- context-preserving
- Git-traceable
- sequential and reviewable

## Core Principles

- One branch per feature.
- Every feature starts from `main`.
- Every phase creates artifacts.
- Every phase requires user review before the next phase.
- Every approved phase creates a Git commit.
- Before PR, the branch is rebased with latest `main`, conflicts are fixed, and validation is rerun.

## Folder Structure

```text
.claude/
  AI_SDLC_README.md
  agent-operational-manual.md
  settings.json
  agents/
    ba-agent.md
    coder-agent.md
    tester-agent.md
    visualiser-agent.md
    verifier-agent.md
    deployer-agent.md
    pr-agent.md
  skills/
  commands/
    session-start.md
    claude-save.md
    phase-close.md
    feature-close.md
  hooks/
    before-phase.md
    after-phase.md
    before-pr.md
  scripts/
    agent_orchestrator.sh
    print-session-state.sh
    guard-main-branch.sh
    remind-phase-close.sh
  plans/
    ba/
    coder/
    tester/
    visualiser/
    verifier/
    deployer/
  journal/
  verification/
  git/
    branching-policy.md
    commit-template.md
    merge-to-main-checklist.md
    pr-template.md
  context/
    feature-index.md
    selector-registry.md
  decisions/
    adr-template.md
  risks/
    active-risks.md
  releases/
  store-metadata/
CLAUDE.md
```

## Root CLAUDE.md vs .claude/

Use the root `CLAUDE.md` as the main project constitution: Flutter architecture, tech stack, coding standards, scraping rules, testing standards. It also points here for process.

Use `.claude/` for everything about *how work gets done*:
- agent definitions (real Claude Code subagents — see below)
- reusable skills
- operational commands (`/session-start`, `/claude-save`, `/phase-close`, `/feature-close`)
- workflow hooks (manual checklists) and registered hooks (`settings.json`)
- the orchestrator and hook scripts
- plans, journals, verification reports
- context registries, decisions, risks
- Git workflow documents

## Agents

Each phase is a real Claude Code subagent, defined with frontmatter in `.claude/agents/`, so it can be invoked directly through the Agent/Task tool instead of manual role-play. See `.claude/agent-operational-manual.md` for the full phase-by-phase entry/exit criteria table.

| Agent | Produces |
|---|---|
| **ba-agent** | Scoped, testable BA plan with requirement IDs |
| **coder-agent** | Implementation limited to the approved BA scope |
| **tester-agent** | Tests derived from BA acceptance criteria, with results |
| **visualiser-agent** | Manual preview on the user's chosen Android/iOS simulator, with feedback filed as GitHub issues |
| **verifier-agent** | Requirement → code → test traceability report and verdict |
| **deployer-agent** | Release readiness, store-prep, and PR-readiness artifacts |
| **pr-agent** (post-phase, not a numbered SDLC phase) | Verified merge checklist, filled PR template, pushed branch, and an opened GitHub PR — never merges |

## Skills

The `skills/` folder contains reusable capability guides used by one or more agents: feature planning, Flutter architecture, scraping selector design, Riverpod state patterns, testing strategy, verification traceability, Git phase commit, release preparation.

## Commands

`.claude/commands/*.md` are Claude Code slash commands, run manually inside a session. They overlap with — but don't replace — the orchestrator script: the script does the git/file mechanics (branch, stub files, commits), while the slash commands are what Claude actually executes to fill in and cross-update artifacts the script doesn't touch (most notably `.claude/context/feature-index.md`, which nothing else updates).

| Command | When to run it | What it does |
|---|---|---|
| `/session-start` | At the start of every session, or after `start-feature` | Reads root `CLAUDE.md`, `.claude/memory.md`, the active feature's row in `feature-index.md`, and the latest plan/journal/verification artifacts; confirms current branch/feature/phase. See `.claude/hooks/before-phase.md`. |
| `/phase-close` | Immediately after an agent produces a phase artifact and you've reviewed/approved it — **before** running `complete-phase` | Saves/confirms the plan artifact, saves the journal, updates `.claude/memory.md`, and updates the feature's row in `.claude/context/feature-index.md`. See `.claude/hooks/after-phase.md`. |
| `/claude-save` | Any time mid-session you want to checkpoint context without closing the phase (e.g. a long BA discussion not yet finalized) | Updates memory, journal, files/commands/tests run, decisions and risks, next handoff — so context survives across sessions even mid-phase. |
| `/feature-close` | Once all 6 phases are approved and verification has passed — **before** running `prepare-pr` | Confirms all phases + verification are complete, rebases on latest `main`, resolves conflicts, reruns validation, updates the test summary and release/PR artifacts. See `.claude/hooks/before-pr.md`. |

**Recommended pairing per phase:** agent produces artifact → you review/approve → `/phase-close` → `./.claude/scripts/agent_orchestrator.sh complete-phase ...` (commits). Same pairing at the end: `/feature-close` → `prepare-pr`.

## Context Registry (`.claude/context/`)

| File | Tracks | Updated by |
|---|---|---|
| `feature-index.md` | Master table of every feature: ID, name, branch, current phase, artifact links, PR status | `/phase-close` and `/feature-close` (the orchestrator script never touches this file — keeping it current is a command/agent responsibility, not automated) |
| `selector-registry.md` | Every scraping selector the app depends on: target, source page, selector type/string, attribute, fallback, last-verified date | **coder-agent**, whenever it adds or changes a selector (per `.claude/skills/scraping-selector-design.md`). The "Last Verified" column is refreshed by **tester-agent**/**verifier-agent** whenever live-scrape tests confirm a selector still works. |

## Architecture Decisions (`.claude/decisions/`)

One file per decision, following `.claude/decisions/adr-template.md` (`NNNN-short-title.md`). Created by the **ba-agent** or **coder-agent** when a non-obvious technical or architecture choice is made that a future session needs the "why" for — a package choice, a deviation from the default layered structure, a scraping-strategy tradeoff. Reviewed by **verifier-agent** during traceability review when a decision affects how a requirement was implemented. Not every feature produces one — only decisions worth remembering do.

## Git Reference Docs (`.claude/git/`)

These 4 files are reference-only — nothing executes them automatically.

| File | Consulted by | When |
|---|---|---|
| `branching-policy.md` | You / any agent | Describes the branch rules the orchestrator's `branch_name()`/`start_feature()` already implement in code — keep both in sync if either changes. Also enforced live by the `guard-main-branch.sh` hook (see Hooks below). |
| `commit-template.md` | You / any agent | Describes the commit message format `complete_phase()` already generates — reference for anyone committing by hand. |
| `merge-to-main-checklist.md` | You, via `/feature-close` | Walked top to bottom before opening a PR. |
| `pr-template.md` | You / **pr-agent**, via `/feature-close` and the pr-agent step after `prepare-pr` | Filled in right before opening the GitHub PR. |

## Supporting Artifact Folders

| Folder | Created by | Populated by | Trigger |
|---|---|---|---|
| `journal/<timestamp>-<feature>-<phase>.md` | Orchestrator `create_journal` (`start-feature`/`complete-phase`) | The active phase's subagent, plus `/phase-close` and `/claude-save` | Every phase |
| `plans/<agent>/<timestamp>-<feature>.md` | Orchestrator `create_phase_plan` | That phase's subagent | Every phase |
| GitHub issues (`bug,visualiser-feedback` labels) | Not tracked under `.claude/` | **visualiser-agent**, one per confirmed defect reported during manual preview | Visualiser phase only. This is the tracking mechanism for visualiser findings — not `risks/active-risks.md`, and it never blocks the phase gate or later phases. |
| `verification/<timestamp>-<feature>.md` | Orchestrator `create_verification_report` | **verifier-agent** | Verifier phase only |
| `releases/` | Orchestrator `prepare_pr` (PR-readiness note) | **deployer-agent** (release-readiness note) | Deployer phase / PR prep — not per-phase |
| `risks/active-risks.md` | Already exists as one running log (not per-feature stubs) | Any agent that spots a risk — most commonly **ba-agent** at scoping and **verifier-agent**/**deployer-agent** at review | Whenever a risk is identified |
| `store-metadata/` | Not auto-created | **deployer-agent** only | Only when a feature actually affects store-facing content (description, screenshots) — most features won't touch it |

## Hooks (`.claude/hooks/` and `.claude/settings.json`)

`.claude/hooks/before-phase.md`, `after-phase.md`, and `before-pr.md` are **manual checklists**, not native Claude Code hooks — "phase" isn't a Claude Code event, so they're cross-linked from the commands that correspond to each moment (`session-start.md` → before-phase; `phase-close.md` → after-phase; `feature-close.md` → before-pr) rather than wired into `settings.json`.

Three *adjacent* moments do map to real Claude Code events, and are registered as actual hooks in `.claude/settings.json`:

| Hook event | Script | What it does |
|---|---|---|
| `SessionStart` | `.claude/scripts/print-session-state.sh` | Prints the "Active State" block of `.claude/memory.md` at the start of every session, so current feature/branch/phase is visible without remembering to run `/session-start`. |
| `PreToolUse` (matcher: `Bash`) | `.claude/scripts/guard-main-branch.sh` | Blocks (exit 2) `git commit`/`git push` while on `main`, `git push --force`/`--force-with-lease`/`-f` on any branch, and `git branch -d`/`-D`/`--delete main` — including when chained with `;`, `&&`, `\|`, or `\|\|` — enforcing `.claude/git/branching-policy.md` automatically instead of relying on discipline. |
| `SubagentStop` | `.claude/scripts/remind-phase-close.sh` | Fires exactly when a phase subagent (`ba-agent`, `coder-agent`, etc.) finishes — the real native "phase just ended" boundary. Reminds you to review the artifact and run `/phase-close`. |

## End-to-End Flow

This is the full path from "I have a feature idea" to "PR is open against the GitHub org repo," using feature `01-bootstrap-app` as the running example.

### 0. One-time setup (you, not the agents)

This is your responsibility, done once, outside the SDLC loop:
- `git init` in this repo (or clone from GitHub if already created)
- Add the remote for the org: `git remote add origin git@github.com:Catholic-Parish-St-Luke-s-Marsden-Park/<repo-name>.git`
- Push `main`

The orchestrator script requires a git repo to exist before `start-feature` will run.

### 1. Start a feature

```bash
./.claude/scripts/agent_orchestrator.sh . start-feature 01 bootstrap-app
```

This:
- checks out and pulls latest `main`
- creates branch `feature/01-bootstrap-app`
- creates a BA plan stub at `.claude/plans/ba/<timestamp>-01-bootstrap-app.md`
- creates a BA journal stub
- updates `.claude/memory.md` (current feature, branch, phase = `ba`, active agent = `BA_AGENT`)
- commits the stub artifacts

### 2. BA phase — consume the ba-agent

In your Claude Code session, invoke the agent directly, e.g.:

> Use the **ba-agent** to turn this into a plan: "Bootstrap the Flutter app shell — theme, navigation, typography, placeholder screens, Riverpod setup, responsive layout — similar in structure to st_luke_frontend_app." Fill in `.claude/plans/ba/01-bootstrap-app-*.md`.

The agent reads root `CLAUDE.md` and `.claude/memory.md`, then fills in the BA plan stub with scope, assumptions, risks, acceptance criteria, and `REQ-F01-00X` requirement IDs. It stops there — it does not write code. When it finishes, the `SubagentStop` hook reminds you to review it.

**You review and approve the BA plan before continuing.**

```
/phase-close
```

Then:

```bash
./.claude/scripts/agent_orchestrator.sh . complete-phase 01 bootstrap-app ba
```

`/phase-close` fills in the journal, memory, and `feature-index.md`; `complete-phase` commits the phase artifacts.

- **Why `/phase-close`:** records your approval before anything is committed — it fills in the journal entry, advances `.claude/memory.md` to the next phase, and updates the feature's row in `feature-index.md`, so the git commit that follows has an accurate paper trail.
- **After it, check:** the BA journal entry is filled in, `.claude/memory.md` shows the phase advancing past `ba`, and the feature's `feature-index.md` row reflects the BA plan link.
- **Why `complete-phase`:** commits the approved BA plan and journal/memory/index updates to git — nothing is durably recorded until this runs.
- **After it, check:** `git log` shows a new commit referencing the BA plan artifact under `.claude/plans/ba/`, and `git status` is clean before starting the coder phase.

### 3. Coder phase — consume the coder-agent

> Use the **coder-agent** to implement the approved BA plan at `.claude/plans/ba/01-bootstrap-app-*.md`.

The agent implements only the approved scope, following the layered architecture in root `CLAUDE.md`, and fills in `.claude/plans/coder/`. If it makes a non-obvious technical choice, it adds a decision record under `.claude/decisions/` and/or a selector entry under `.claude/context/selector-registry.md`.

**You review the code and approve before continuing.**

```
/phase-close
```
```bash
./.claude/scripts/agent_orchestrator.sh . complete-phase 01 bootstrap-app coder
```

- **Why `/phase-close`:** records your approval of the implementation before it's committed — updates the journal, advances `.claude/memory.md` past `coder`, and updates `feature-index.md`.
- **After it, check:** the coder journal entry references the code changes and any decision records or selector-registry entries added, and `.claude/memory.md` shows the next phase as `tester`.
- **Why `complete-phase`:** commits the entire working tree (`git add -A`) — the actual code changes land in the same commit as the plan/journal, not a separate manual commit.
- **After it, check:** `git status` is clean, `git log` shows a commit including both the code changes and the coder plan/journal, and nothing unrelated was swept in by the `git add -A`.

### 4. Tester phase — consume the tester-agent

> Use the **tester-agent** to validate feature 01 against the BA acceptance criteria.

The agent derives tests from the BA plan's acceptance criteria (not guesswork), runs them, and records commands/results/gaps in `.claude/plans/tester/` and the journal.

**You review test results and approve before continuing.**

```
/phase-close
```
```bash
./.claude/scripts/agent_orchestrator.sh . complete-phase 01 bootstrap-app tester
```

- **Why `/phase-close`:** records your approval of the test results before it's committed — updates the journal, advances `.claude/memory.md` past `tester`, and updates `feature-index.md`.
- **After it, check:** the tester journal entry lists the commands run and their results/gaps, and `.claude/memory.md` shows the next phase as `visualiser`.
- **Why `complete-phase`:** commits the test plan, results, and journal to git so the tested state is durably recorded before manual preview.
- **After it, check:** `git log` shows a commit referencing the tester plan under `.claude/plans/tester/`, and `git status` is clean before starting the visualiser phase.

### 5. App-Visualiser phase — consume the visualiser-agent

> Use the **visualiser-agent** to let me preview feature 01 on a simulator.

The agent asks which platform to preview (Android, iOS, or both), boots or creates the simulator/emulator, and runs the app on it (`flutter run -d <device_id>`). It then hands control back to you to try the app manually. Whatever you report is parsed into distinct defects, confirmed with you as a list, and filed as one GitHub issue per defect (labels `bug,visualiser-feedback`) — it does not loop back to Coder or BA, and does not block progress even if issues remain open.

**You review the filed issues and approve — confirming the preview happened and feedback was captured, not that every issue is fixed — before continuing.**

```
/phase-close
```
```bash
./.claude/scripts/agent_orchestrator.sh . complete-phase 01 bootstrap-app visualiser
```

- **Why `/phase-close`:** records your approval before it's committed — updates the journal, advances `.claude/memory.md` past `visualiser`, and updates `feature-index.md`. Approval here means the preview happened and feedback was captured, not that every filed issue is fixed.
- **After it, check:** the visualiser journal entry lists the platform(s) previewed and links the filed GitHub issues, and `.claude/memory.md` shows the next phase as `verifier`.
- **Why `complete-phase`:** commits the visualiser journal/plan artifacts to git — the filed GitHub issues themselves live outside `.claude/` and are not part of this commit.
- **After it, check:** `git log` shows a commit referencing the visualiser plan/journal, the GitHub issues (labels `bug,visualiser-feedback`) are visible in the repo's Issues tab, and `git status` is clean before starting the verifier phase.

### 6. Verifier phase — consume the verifier-agent

> Use the **verifier-agent** to verify feature 01.

The agent builds the requirement → code → test traceability matrix and issues a pass / conditional pass / fail verdict in `.claude/verification/`. It does not modify code or tests — it only reports mismatches, and flags any risk it finds in `.claude/risks/active-risks.md`.

**You review the verdict and approve before continuing.**

```
/phase-close
```
```bash
./.claude/scripts/agent_orchestrator.sh . complete-phase 01 bootstrap-app verifier
```

- **Why `/phase-close`:** records your approval of the verification verdict before it's committed — updates the journal, advances `.claude/memory.md` past `verifier`, and updates `feature-index.md`.
- **After it, check:** the verifier journal entry links the traceability report, `.claude/memory.md` shows the next phase as `deployer`, and any risks the agent flagged appear in `.claude/risks/active-risks.md`.
- **Why `complete-phase`:** commits the traceability report and verdict to git so the verification outcome is durably recorded before deployment prep begins.
- **After it, check:** `git log` shows a commit referencing the report under `.claude/verification/`, and `git status` is clean before starting the deployer phase.

### 7. Deployer phase — consume the deployer-agent

> Use the **deployer-agent** to prepare feature 01 for release and PR.

The agent prepares local release-readiness (build/format/analyze checks), store-prep notes, PR-readiness notes, and rollback notes under `.claude/plans/deployer/`, `.claude/releases/`, `.claude/store-metadata/`. It never publishes or submits anything automatically.

**You review and approve before continuing.**

```
/phase-close
```
```bash
./.claude/scripts/agent_orchestrator.sh . complete-phase 01 bootstrap-app deployer
```

- **Why `/phase-close`:** records your approval of release readiness before it's committed — updates the journal, advances `.claude/memory.md` past `deployer`, and updates `feature-index.md`.
- **After it, check:** the deployer journal entry references the release-readiness notes, `.claude/memory.md` shows the next phase as PR prep, and `feature-index.md` reflects the deployer artifact link.
- **Why `complete-phase`:** commits the deployer's release-readiness, store-prep, and PR-readiness artifacts to git before you move on to `/feature-close`.
- **After it, check:** `git log` shows a commit referencing the deployer artifacts under `.claude/releases/` and/or `.claude/store-metadata/`, and `git status` is clean before running `/feature-close`.

### 8. Prepare PR and merge

```
/feature-close
```

Claude confirms all phases + verification are complete, rebases on latest `main`, resolves conflicts, reruns validation, and updates the test summary and release/PR artifacts. Then:

```bash
./.claude/scripts/agent_orchestrator.sh . prepare-pr 01 bootstrap-app
```

This writes a PR-readiness note with an unchecked checklist and commits it. Then:

> Use the **pr-agent** to walk the checklist, fill in the PR template, push, and open the PR.

The agent walks `.claude/git/merge-to-main-checklist.md` top to bottom against real evidence (re-running validation where needed), fills in `.claude/git/pr-template.md` (feature summary, artifact links, validation results), and pauses for your approval before touching git or GitHub. Once approved, it pushes the branch and opens the PR against the GitHub org repo (`Catholic-Parish-St-Luke-s-Marsden-Park`), then reports the PR URL and stops.

**Merging is not automated.** Review and merge the PR manually from the GitHub UI.

## Standard Commands

### Start feature
```bash
./.claude/scripts/agent_orchestrator.sh . start-feature <feature-id> <feature-slug>
```

### Complete a phase
```bash
./.claude/scripts/agent_orchestrator.sh . complete-phase <feature-id> <feature-slug> <ba|coder|tester|visualiser|verifier|deployer>
```

`complete-phase` stages and commits the **entire working tree** (`git add -A`), not just the phase's SDLC bookkeeping files — this is intentional so the coder phase's actual code changes land in the same commit as its plan/journal, rather than requiring a separate manual commit. `.gitignore` already excludes build artifacts. Make sure nothing unrelated is sitting in the working tree before running it.

### Prepare PR
```bash
./.claude/scripts/agent_orchestrator.sh . prepare-pr <feature-id> <feature-slug>
```

## Required Human Review Gates

You must review and approve, in order, before the next phase may begin:
- BA scope
- implementation
- tests
- manual preview / app-visualiser feedback
- verification
- deployment readiness
- PR readiness

## Git Rules

- One feature branch per feature, named `feature/<id>-<slug>`.
- Start from `main`.
- Commit after every approved phase (the orchestrator does this automatically).
- Include artifact paths in commit messages (see `.claude/git/commit-template.md`).
- Rebase with latest `main` before PR.
- Rerun validation after rebase.
- Direct commits/pushes to `main`, force-pushes, and deleting `main` are blocked by the `guard-main-branch.sh` hook.

## Suggested Daily Workflow

1. Session starts — the `SessionStart` hook auto-prints current feature/branch/phase from `.claude/memory.md`. Run `/session-start` for the fuller check (reads CLAUDE.md, feature-index row, latest artifacts).
2. Work only in the current approved phase, using that phase's subagent.
3. Save phase artifacts (the subagent does this as part of its output). The `SubagentStop` hook reminds you when it's done.
4. Run `/phase-close`, then `complete-phase`, to update journal/memory/feature-index and commit.
5. Stop and get your review/approval before continuing to the next phase.

## Important Note

This scaffold gives you the structure and operating model. It does not replace engineering judgment. Human review remains mandatory at every phase.
