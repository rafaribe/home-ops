---
name: fable-mode
description: >
  Enforces staged execution discipline on large tasks: a written stage plan,
  delegation to named fable agents where the runtime supports it, a failable
  verification check at each stage, and a skeptical self-review before delivery.
  Trigger when the user explicitly asks ("do this thoroughly", "be systematic",
  "deep work mode") OR when the task objectively spans multiple files, multiple
  sources, or multiple sessions. Do NOT trigger on ordinary multi-step requests
  that a direct attempt handles fine. For a run pinned to a specific model, use
  fable-opus, fable-sonnet, or fable-haiku instead. Always-on guardrails
  (verify-before-flag, warning batching, sed safety) live in the companion
  execution-guardrails skill.
---

# Fable Mode (v3)

Decompose before acting, delegate to named agents, verify with checks that can
fail, self-critique before delivery.

The skill shapes procedure, not capability: benchmarked 2026-07 — on short graded
tasks Opus/Sonnet score the same with or without it; the measured value shows on
open-ended research (real sources vs. plausible fabrication) and on enforcing
verification at lower tiers.

## When NOT to use this

One obvious correct approach, fits in a single pass → do it directly.
Staging a trivial task buries the answer under ceremony.

## v3 delegation rule — the load-bearing change

Prose-level "you may spawn a worker" gets skipped: the model runs the task inline
in the main thread. Delegation is therefore structural now:

- If the fable agents are installed (`fable-orchestrator`, `fable-worker-sonnet`,
  `fable-worker-haiku`, `fable-verifier`), route large tasks through
  **@fable-orchestrator** — an Opus agent with no Write/Edit tool. It cannot
  produce artifacts itself; every artifact must come from a named worker, every
  deliverable can face a cold **@fable-verifier** pass.
- If they are not installed, run the loop inline (below) on the current model —
  and say so, since inline mode loses the enforcement.

## Core loop (inline fallback; also what the agent definitions encode)

**1. Stage map first.** Numbered stages, expected output each, one verifiable
artifact per stage. Living document; at most two full replans per run — a third
means requirements-level ambiguity, go back to the user.

**2. Delegate by name where possible.** Sonnet-worker for reasoning stages,
Haiku-worker for bulk mechanical stages, verifier for cold checks. Workers get:
task, exact output path, context, named pass condition. Workers don't spawn
workers. Cap concurrency.

**3. Verify with a check that can fail.** A test that runs, a file in the
expected shape, a source actually fetched, an output diffed against spec. "Looks
right" is not a check. Name the exact command/file/comparison or mark the stage
unverified. A fix at stage N re-runs the checks it invalidated.

**4. Self-critique before delivery.** Skeptical read; fix or flag a real weakness;
a clean pass stated plainly beats a manufactured caveat. Beyond capability → name
what was attempted and where it failed.

## Domain checks

Software: touched files were opened; named test command passes; one error path shown.
Research: every load-bearing claim maps to a source fetched this run; training-memory claims labeled.
Data: shape printed first; quality assertions run with output; one subtotal recomputed.
Documents: rendered file read back against spec line by line.
Long-running: work log, testable done criteria, each continuation re-reads the log.

## Operational rules

Live in the always-on **execution-guardrails** skill (verify-before-flag, warning
threshold of three, word-boundary find-and-replace). They bind every model, every
task, whether or not this loop runs.
