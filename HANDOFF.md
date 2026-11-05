# HANDOFF — ProofRun (start of build, Thu 5 Nov 2026 evening, Asia/Dhaka)

## Read first
1. `CLAUDE.md` — how to work here, the security invariants, slices S1–S10.
2. `docs/SPEC.md` (currently at repo root: `SPEC.md`) — **locked** spec **v1.2**. Don't redesign; ask MHA before any change (add a row to §18).

## Where we are
- Architecture and spec: **done and locked** (1.5 days of design; don't reopen it).
- Repo: https://github.com/kmmohaimenulhaque-code/Vultr-comp — contains `CLAUDE.md`, `docs/SPEC.md`, `deploy/*.example`, this file. **No code yet.**
- Spec v1.1 applied (Thu 5 Nov, MHA OK): **D17** VM → VX1 (§14, `VM_HOURLY_USD=0.306`) · **D18** Mode L live-URL check promoted to P0-light (§5.8; no vault, no secrets, SSRF guard, live badges) · **D19** CSV batch import in P0 (§12, board scales to hundreds of rows) · **D20** 1–2 skills vendored at build time, pinned (§2 P0.11). **D21** deterministic Explorer / robustness sweep (§7.5; quick mode P0 as S6c, full mode P1; findings are evidence, only G6 changes a verdict; destructive controls skipped on live sites). Motivating example: Space Apps judges screening ~600 entries in ~2 days (throughput = estimate, to be measured).
- Skill candidate (not vendored yet, needs MHA OK in S6): `anthropics/skills` → `skills/webapp-testing`, Apache-2.0, commit `ca45fc496a3436251f191354091d557da31c15b5`.
- VM: **`vx1-g-8c-32g-480s`** (8 vCPU / 32 GB / 480 GB local NVMe, Dedicated CPU VX1, Atlanta, Ubuntu 24.04, SSH key). Being deployed by MHA; IP not shared yet.
- Vultr Serverless Inference: subscription created (label `proofrun`). Key is with MHA — it goes **only** into `/etc/proofrun/control.env` on the VM. Never paste it in chat or git.
- Models: Planner/Prober/Fixer `deepseek-v4.1-flash-1017` ($0.15/$0.60 per 1M); Verifier `nemotron-3-nano-omni-30b-a3b-reasoning` ($0.10/$0.25, **1 image per request**). Prices confirmed in console.

## Next up (tonight → S1, then S2)
1. SSH into the VM; clone the repo to `/opt/proofrun`.
2. Write + run `deploy/bootstrap.sh` (Docker, `proofrun` user, dirs), `firewall.sh`, `slots-init.sh`, `slot-reset.sh` (+ sudoers line), `scripts/keygen.py`.
3. Put the key in `/etc/proofrun/control.env` (MHA types it; you give the command).
4. `make smoke-inference` (text + vision, prints requested vs returned model) and `make test-firewall` → S1 done.
5. Timebox 30 min: gVisor + shared-netns pod + Chromium. If not clean, keep `runc`.
6. Verify on the VM and tick in CLAUDE.md §13: cgroup `pids.events` path · tmpfs writable by uid 10001 · DNS still works after firewall.

## Schedule (Dhaka) — ~10–12 focused h/day, 7 h sleep
Thu night S1–S2 · Fri S3–S6 + **S6b Mode L + CSV import (~4–5 h)** · Sat early **S6c Explorer quick mode (~4–5 h)** · Sat S7–S10, **freeze 18:00**, then video + slides · **Submit Sun 8 Nov by 09:00**.
Behind schedule → cut order in SPEC §17 (board CSV export/filters, vendored skills, Explorer full mode and Explorer edge-case set go before Mode L itself). Never cut: pod airgap, policy gate, evil detonation, signed receipts, vision verifier, showroom.

## Open checks
- Billing: confirm Serverless Inference invoices are paid from the $200 credit.
- Deadline shown inconsistently on lablab (09:00 Dhaka / 18:00 EST / 22:00 UTC) → we target 09:00 Dhaka.
- Domain for HTTPS: own domain or `<ip-dashed>.sslip.io` — test on Sat, not Sun.
- Keep the VM running through judging (~$7.3/day); snapshot before the freeze.

## Working with MHA
- Short replies: what changed, test result, next step, one question max.
- Console/DNS/GitHub actions → numbered steps for MHA.
- Laptop has 4 GB RAM: **all** Docker/Chromium/dev work happens on the VM.
- GitHub push access from cloud sessions wasn't enabled before; on the VM, MHA's own git credentials or a deploy key are needed.

## Already decided — don't revisit
No 128 GB VM · no runtime skill installer in P0 (P1, pinned + approved) · no Mode L login vault in P0 · no Obscura/stealth · no CAPTCHA/SSO automation · no numeric LLM scores · no Kimi · credentials model = SPEC §11 (classes A–D).
