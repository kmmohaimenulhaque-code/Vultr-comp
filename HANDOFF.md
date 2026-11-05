# HANDOFF — ProofRun (start of build, Thu 5 Nov 2026 evening, Asia/Dhaka)

## Read first
1. `CLAUDE.md` — how to work here, the security invariants, slices S1–S10.
2. `docs/SPEC.md` — **locked** spec. Don't redesign; ask MHA before any change (add a row to §18).

## Where we are
- Architecture and spec: **done and locked** (1.5 days of design; don't reopen it).
- Repo: https://github.com/kmmohaimenulhaque-code/Vultr-comp — contains `CLAUDE.md`, `docs/SPEC.md`, `deploy/*.example`, this file. **No code yet.**
- Pending small edit if not done yet: SPEC §14 VM line → VX1 `vx1-g-8c-32g-480s`, Atlanta, $0.306/hr; `VM_HOURLY_USD=0.306` in `deploy/control.env.example`; decision D17.
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
Thu night S1–S2 · Fri S3–S6 · Sat S7–S10, **freeze 18:00**, then video + slides · **Submit Sun 8 Nov by 09:00**.
Behind schedule → cut order in SPEC §17. Never cut: pod airgap, policy gate, evil detonation, signed receipts, vision verifier, showroom.

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
No 128 GB VM · no runtime skill installer · no Obscura/stealth · no CAPTCHA/SSO automation · no numeric LLM scores · no Kimi · credentials model = SPEC §11 (classes A–D).
