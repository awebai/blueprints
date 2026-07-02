---
name: incident-response
description: >-
  Runs a live-service incident end to end - detect, triage by severity and
  impact, mitigate to restore service first, find the root cause, and land a
  durable follow-up fix. Use when a live service is failing, error rates or
  latency spike, a dependency is unavailable, a deploy may have regressed, or the
  real URL is not working.
---

# Incident Response

Run a live-service incident from the first signal to a fix that holds. Restore
service first, understand it second, and make sure it can't recur the same way.

## Detect

- Confirm the signal is real before raising it. **Reproduce it against the live
  service** — the real URL, through the real public delivery path — not localhost,
  not the test suite.
- Capture the evidence as you find it: the failing probe output, the status code,
  the log line, the error rate, the timestamp. You'll need it for triage and for
  the write-up.
- Distinguish a self-healing blip from a sustained failure. Brief dependency
  errors that clear in seconds may be noise; a sustained failure or rising trend
  is an incident. Watch the trend, not one sample.

## Triage

Set severity by **impact**, not by how alarming the alert looks.

- **SEV-1** — customer-facing and broad: the live URL is down or erroring for
  everyone, a critical flow fails, data is at risk. Page the human, mitigate now.
- **SEV-2** — degraded or partial: elevated errors, slow latency, one feature
  broken, a subset of users affected. Mitigate promptly, escalate if it worsens.
- **SEV-3** — minor or self-healing: a recovered burst, a cosmetic issue, no real
  user impact. Track it, watch it, fix it in normal flow.

Name the blast radius: who is affected, how badly, and whether it is
customer-facing. Customer-facing impact or a risky mitigation goes to the human
before you act.

## Mitigate — restore service first

Getting users working again comes before understanding why.

- Pick the fastest **safe** path back: roll back the last deploy, fail over, shed
  load, clear a bad cache, disable the broken feature. A deploy is the most likely
  cause of a fresh incident — rolling it back is often the fastest mitigation.
- A mitigation that is risky, irreversible, or touches production data is the
  human's call. Escalate with a recommendation; don't run it solo.
- A mitigation is **temporary by definition**. It stops the bleeding; it does not
  close the incident. Say "mitigated, watching" — never "all clear" — until you
  have root-caused and verified.

## Root cause — second, never skipped

Once service is restored, find the actual cause. This is where firefighting
becomes reliability.

- **Reproduce before you investigate.** If you can't make it happen on demand,
  you can't prove you fixed it.
- **Read the error carefully.** The stack trace, the status code, the log line
  usually name the cause. Don't skip to your first guess.
- **One hypothesis, one fix, test after each.** Changing several things at once
  tells you nothing about which mattered. Isolate the cause.
- **Never patch the symptom.** A restart that clears the error without explaining
  it is a mitigation, not a fix. If you don't understand why it broke, you are
  not done.

## Follow up

- **Land the durable fix.** It addresses the cause, not the symptom. Verify it
  **on the live service** — the real URL, a real request, both browser and curl —
  and watch for a few minutes; some regressions only show under real traffic or
  after a cache turns over.
- **File a tracked task** for any fix that can't ship in the moment, with the
  severity, the cause, and the acceptance criteria, so it doesn't get lost.
- **Write the lesson.** What broke, why, how it was caught, and what makes the
  next incident shorter — a better probe, an alert, a guardrail. An incident is
  closed when it can't recur the same way, not when the page stops paging.

## Guardrails

- Reproduce before investigating; verify the fix on the live URL.
- Restore service first, root-cause second, never skip the root cause.
- Never declare "all clear" until you've verified it holds — a false all-clear is
  worse than an open incident.
- Escalate customer-facing comms, risky or irreversible mitigations, and anything
  touching production data to the human, early, with a recommendation.
