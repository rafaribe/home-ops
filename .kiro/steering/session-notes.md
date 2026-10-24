# Session Notes in `.ai/` — Always Record, Unprompted

Write findings to the repo's `.ai/` folders as part of the work. Do this without being asked. The user should never have to say "record this" or "write this down for later".

## When to write

Any task that investigates, troubleshoots, or takes several steps, and every time one of these happens:

- You learn something that would be costly to rediscover (a root cause, an IP, a quirk, a dead end).
- You make or change a decision, or hit a blocker.
- A step is left half-done, or something is waiting on the user.
- You find that an earlier statement, yours or a note's, was wrong.

Write as you go, not only at the end. Update the note before you finish a turn that produced new findings, so it is already current if the session stops.

## Where

Use the `.ai/` folder nearest to the area worked on:

| Area | Folder |
|---|---|
| Talos, TuringPi/BMC, node OS, `talconfig.yaml` | `talos/.ai/` |
| GitHub Actions, CI, runners | `.github/.ai/` |
| Cluster-wide, Flux, Ceph, apps, anything else | `.ai/` (repo root) |

Create the folder if it is missing.

## Naming and structure

- File: `<topic>-YYYY-MM-DD.md`, using the date the topic started. Update the existing note for the same topic instead of creating a new one.
- If a topic has several overlapping notes, write one `<topic>-handoff-YYYY-MM-DD.md` and mark the older ones as superseded at their top.
- Put a "start here" summary at the top, then these sections as relevant:
  1. Current state (what is true now, and when it was checked)
  2. What was done, including every change made to a system, even small ones such as a power cycle
  3. Findings, with the evidence (command, output, URL)
  4. Not verified, kept separate from confirmed facts
  5. Decisions needed from the user
  6. Next steps, in order, with the commands to run
  7. Mistakes and corrections: state plainly what was wrong earlier

## Rules

- **Never record secrets**: passwords, tokens, API keys, BMC logins, private keys, secret values. Write "provided by the user in chat" or the Akeyless path instead. Re-read the note for secrets before saving.
- Mark unconfirmed claims as hypotheses. Do not present a guess as a finding.
- Correct wrong statements in place and say they were corrected. Do not leave a wrong claim standing.
- Record destructive steps that were not done, so the next session knows nothing was changed.
- At the start of work on a topic, read the newest matching note in the relevant `.ai/` folder before probing the cluster again.
- `.ai/` is gitignored. Do not commit or stage these notes unless the user asks.
- In the final reply, give the note path in one line. Do not paste the note's content.
