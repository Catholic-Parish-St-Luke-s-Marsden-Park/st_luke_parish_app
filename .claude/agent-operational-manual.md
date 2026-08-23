# Agent Operational Manual

Single reference index for how the five SDLC agents fit together. Each agent's full role, inputs, outputs, and rules live in its own file under `.claude/agents/` — this manual only summarizes phase entry/exit criteria and handoffs. See `.claude/AI_SDLC_README.md` for the full end-to-end usage walkthrough.

| Phase | Agent doc | Entry criteria | Exit criteria (produces) | Approval gate |
|---|---|---|---|---|
| 1. BA | [.claude/agents/ba-agent.md](agents/ba-agent.md) | Feature request exists; branch created via `start-feature` | BA plan in `.claude/plans/ba/` with requirement IDs (`REQ-FXX-001`), in/out of scope, acceptance criteria | User approves BA plan before Coder starts |
| 2. Coder | [.claude/agents/coder-agent.md](agents/coder-agent.md) | BA plan approved | Code changes scoped to the BA plan; coder plan in `.claude/plans/coder/`; journal entry | User approves implementation before Tester starts |
| 3. Tester | [.claude/agents/tester-agent.md](agents/tester-agent.md) | Coder plan approved | Tests derived from BA acceptance criteria; tester plan in `.claude/plans/tester/`; pass/fail results in journal | User approves test results before Verifier starts |
| 4. Verifier | [.claude/agents/verifier-agent.md](agents/verifier-agent.md) | Tester plan approved | Verifier plan in `.claude/plans/verifier/`; verification report in `.claude/verification/` with requirement→code→test traceability matrix; pass/conditional pass/fail verdict | User approves verification before Deployer starts |
| 5. Deployer | [.claude/agents/deployer-agent.md](agents/deployer-agent.md) | Verification passed | Deployer plan in `.claude/plans/deployer/`; release readiness, store-prep, and PR-readiness notes; rollback notes | User approves deployment readiness before `prepare-pr` / merge |

## Handoff rule

No agent may skip a phase, and no phase may start without the user explicitly approving the previous phase's artifact. `.claude/memory.md` always reflects the current feature, branch, phase, and active agent — check it before resuming any session (see `.claude/commands/session-start.md`).

## Lifecycle hooks

`.claude/hooks/before-phase.md`, `after-phase.md`, and `before-pr.md` describe the checks Claude should run immediately before starting a phase, immediately after finishing one, and immediately before raising a PR, respectively.
