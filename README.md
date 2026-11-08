# ProofRun

<p align="center">
  <strong>Containment-first verification for untrusted software</strong><br>
  <em>Run it. Probe it. Contain it. Prove what happened.</em>
</p>

<p align="center">
  <a href="https://github.com/kmmohaimenulhaque-code/Vultr-comp"><img src="https://img.shields.io/badge/status-hackathon%20prototype-6f42c1" alt="Hackathon prototype"></a>
  <a href="https://lablab.ai/"><img src="https://img.shields.io/badge/lablab.ai-Vultr%20Agent%20Rush-00a8e8" alt="lablab.ai Vultr Agent Rush"></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-MIT-2ea44f" alt="MIT License"></a>
  <a href="SPEC.md"><img src="https://img.shields.io/badge/spec-locked%20v1.0-f2cc60" alt="Locked specification v1.0"></a>
</p>

> **Important status note — 8 November 2026:** this repository contains the ProofRun specification,
> deployment templates, configuration examples, and the first demo fixtures. The implementation
> directories referenced by the specification and Makefile (`orchestrator/`, `sandbox/`, `scripts/`,
> `tests/`, and `web/`) are not present in the current repository snapshot. The commands below are
> therefore separated into **available now** and **planned when the implementation is restored**.
> This README does not claim that an unavailable command has been tested.

## About the project

ProofRun is a proposed containment-first verification agent for the **lablab.ai VULTR Agent Rush
hackathon**, in the **Blast Radius Zero** track. It is designed to help organizers evaluate
untrusted GitHub submissions without running them directly on a laptop or in a personal browser.

The locked design combines:

- disposable Docker stages for fetching, building, and running a submission;
- a Stage 2 pod with a holder, application, and Playwright probe sharing a loopback-only network namespace;
- deterministic policy gates for commands, README shell blocks, probe AST, and fixer patches;
- a sinkhole, canaries, network hooks, and resource telemetry for containment evidence;
- Vultr Serverless Inference for planning, probing, fixing, and visual verification;
- rule-based proposed tiers backed by canonical, Ed25519-signed receipts; and
- human approval or override rather than an opaque model-generated score.

The design is documented in [`SPEC.md`](SPEC.md), which is the source of truth for security and
behavioral decisions.

## Why it exists

Static review cannot establish that a project actually builds or that its README claims work.
Running unknown code directly on a developer machine is unsafe. ProofRun is intended to make that
verification observable and bounded:

```text
GitHub repository
       │
       ▼
Fetch → policy scan → plan → build → run → Playwright probe → visual verification
       │                                                        │
       └──────────── evidence, telemetry, and signed receipt ───┘
                                  │
                                  ▼
                      proposed tier → human decision
```

The intended safety posture is **containment plus detection**, not a claim of perfect prevention.
The project must never be described as injection-proof, as detecting every exfiltration attempt, or
as replacing human judges.

## Current repository contents

| Path | Purpose | Current status |
| --- | --- | --- |
| [`SPEC.md`](SPEC.md) | Locked product, architecture, security, and delivery specification | Present |
| [`CLAUDE.md`](CLAUDE.md) | Contributor and security invariants for the planned implementation | Present |
| [`Makefile`](Makefile) | Intended setup, test, smoke, deployment, and demo entry points | Present; several targets reference absent modules |
| [`pyproject.toml`](pyproject.toml) | Python 3.12 project metadata and dependencies | Present |
| [`control.env.example`](control.env.example) | Class A control-plane configuration template | Present |
| [`site-credentials.env.example`](site-credentials.env.example) | Class C credential format example for a later phase | Present |
| [`deploy/`](deploy) | Bootstrap, firewall, slot, systemd, and Caddy templates | Present |
| [`fixtures/clean`](fixtures/clean) | Intended clean-submission fixture (F1) | Present, fixture files only |
| [`fixtures/broken-env`](fixtures/broken-env) | Intended one-fix recovery fixture (F2) | Present, fixture files only |
| [`docs/demo-repos.md`](docs/demo-repos.md) | Planned demonstration fixture/repository inventory | Present |
| `orchestrator/`, `sandbox/`, `scripts/`, `tests/`, `web/` | Runtime, sandbox, tooling, test, and UI implementation | Not present in this snapshot |

## Prerequisites

### For the full deployment

The locked specification targets a dedicated **Vultr Cloud Compute VM** running Ubuntu 24.04.
It calls for 8 vCPU, 32 GB RAM, and 512 GB NVMe so that up to four jobs can be isolated in
parallel. Docker Engine, Python 3.12, Git, iptables, and Caddy are required by the deployment
design.

Development is intended to happen on the VM. Do not run untrusted fixtures, Docker, or Chromium
directly on a low-memory personal machine.

### Access limitation

During this hackathon work, the required **Vultr VM was not accessible from the project owner's
account because of technical issues**. Consequently, the deployment, Docker sandbox, firewall,
inference, and HTTPS behavior could not be verified on a live Vultr VM from this repository
snapshot. Any production or demo deployment requires resolving that account/access issue first.

## Setup

### 1. Clone the repository

```bash
git clone https://github.com/kmmohaimenulhaque-code/Vultr-comp.git
cd Vultr-comp
```

### 2. Inspect the locked design

Before changing security-sensitive behavior, read:

```bash
less SPEC.md
less CLAUDE.md
```

`SPEC.md` is explicitly locked. Do not silently change its decisions; record an approved change in
its decision log.

### 3. Prepare Python

The project metadata requires Python 3.12 or newer:

```bash
python3 --version
python3 -m venv .venv
source .venv/bin/activate
python -m pip install --upgrade pip
python -m pip install -e '.[dev]'
```

In the current snapshot, the runtime package directories are absent, so installation and execution
should be treated as preparation for the restored implementation rather than proof that the service
is operational.

### 4. Configure the control plane

Never commit real credentials. On the VM, copy the template into the protected system location and
fill it with values supplied through the appropriate secure channel:

```bash
sudo install -m 640 -o root -g proofrun \
  control.env.example /etc/proofrun/control.env
sudoedit /etc/proofrun/control.env
```

The template includes the Vultr Serverless Inference endpoint and model settings, budget limits,
admin token, signing-key path, sandbox image, slot paths, and public rate limits. The real file
must remain outside Git. Class C site credentials are a separate format and must not be put into
`control.env`.

### 5. Prepare the VM deployment

After Docker is installed and the VM account has the required privileges, the deployment templates
are intended to be run from the repository root:

```bash
sudo bash deploy/bootstrap.sh
```

This provisions the `runner` and `proofrun` users, creates the ProofRun directories, initializes
four slot images, installs the slot reset helper, and applies the Docker bridge firewall rules.
Review every command before running it on a real host. The bootstrap script is not a substitute for
testing the host firewall and Docker configuration.

The intended service layout is:

```text
/opt/proofrun                  application checkout
/etc/proofrun/control.env      protected Class A configuration
/etc/proofrun/keys/            receipt signing keys
/var/lib/proofrun/slots/       disposable slot mounts
/var/lib/proofrun/jobs/        job artifacts and receipts
```

The included systemd templates are `deploy/proofrun.service`,
`deploy/proofrun-firewall.service`, and `deploy/proofrun-slots.service`. The included
`deploy/Caddyfile` reverse-proxies HTTPS traffic to the orchestrator on `127.0.0.1:8000` and
sets a restrictive Content Security Policy.

## Available files and demonstration fixtures

The repository currently includes two fixture descriptions:

- **F1 — `fixtures/clean`**: intended clean FastAPI calculator submission, expected to verify
  without a fix.
- **F2 — `fixtures/broken-env`**: intended missing-`APP_SECRET` submission, expected to fail
  initially and recover after one labeled `.env` fix.

The specification also defines planned F3 and F4 fixtures:

- **F3 — vaporware**: a claim mismatch where the report endpoint fails.
- **F4 — evil submission**: a containment test covering prompt-injection text, `curl | sh`,
  canary output/exfiltration, metadata probing, PID exhaustion, and disk exhaustion.

F3 and F4 are not present in the current tracked tree. Do not run any fixture outside the eventual
sandbox driver.

## Intended commands

The Makefile records the project command surface. These commands become usable only after the
referenced implementation is restored and the VM prerequisites are available:

| Command | Intended purpose |
| --- | --- |
| `make setup` | Create a virtual environment and install the project |
| `make image` | Build the `proofrun-sandbox` image |
| `make lint` | Run Ruff, including security rules |
| `make test` | Run the unit test suite without Docker |
| `make test-firewall` | Apply/check the Docker bridge firewall |
| `make pod-hello` | Smoke-test the Stage 2 pod |
| `make test-containment` | Run the evil fixture through the driver |
| `make smoke-inference` | Exercise text and vision inference without printing secrets |
| `make dev` | Start FastAPI on `127.0.0.1:8000` |
| `make showdown` | Run the F1–F4 demonstration batch |
| `make showroom` | Record signed demonstration results |
| `make check-secrets` | Scan tracked files for secret patterns |

**Current limitation:** these targets reference files that are not included in this repository
snapshot. They are documented as the intended interface, not as completed functionality.

## Security invariants

The following rules are non-negotiable in the locked design:

1. Submission code runs only inside the staged sandbox; it never runs on the host.
2. The Stage 2 holder owns a `--network none` namespace; the app and probe join it with
   `container:<holder>`.
3. Container environment variables are constructed in one dedicated helper, and host secrets never
   enter submission containers.
4. Docker sockets, host configuration, the checkout, the jobs root, and other jobs' folders are not
   mounted into a submission.
5. Commands are argument lists, never shell strings; `shell=True`, `os.system`, and equivalent
   shortcuts are forbidden.
6. README text, logs, DOM text, manifests, and other untrusted content are sanitized, bounded, and
   passed as data rather than instructions.
7. Deterministic guards outrank model output. Models can lower a verdict, never raise it past a
   guard.
8. Tiers come only from receipt evidence and remain **Proposed** until a human approves or overrides.
9. Airgap-caused failures are `UNVERIFIABLE`, not failures attributed to a submission.
10. Containers are removed, timeouts kill them, and slots are reset after every job and attempt.

Read [`SPEC.md`](SPEC.md) and [`CLAUDE.md`](CLAUDE.md) before implementing or modifying any of
these controls.

## Planned result tiers

The rule-based tier order in the specification is:

| Tier | Meaning |
| --- | --- |
| 🔴 **Quarantined — needs human review** | Hostile behavior or serious containment evidence |
| ⚫ **Needs human** | Infrastructure or unresolved evidence prevents a reliable decision |
| 🟡 **Claim mismatch** | The application runs, but a claimed behavior is contradicted |
| 🔵 **Runs after a small fix** | The one allowed labeled fixer patch makes the submission run |
| 🟢 **Verified** | The submission runs and its claims are supported with no disqualifying flags |

These are proposed outcomes, not an automatic disqualification system and not numeric model scores.

## Development status

This checkout is an early hackathon prototype/scaffold. The specification and operational guardrails
are substantially more complete than the checked-in runtime implementation. The next engineering
milestone is to restore the P0 vertical slices in the order specified by `CLAUDE.md`: bootstrap,
sandbox, driver, detection, policy gates, agents, evidence/receipts, API/queue, UI, and deployment.

Because the Vultr VM was inaccessible from the owner's account due to technical issues, there is
currently no honest claim of a live URL, successful VM deployment, measured showdown run, signed
receipt batch, or verified inference call associated with this checkout.

## Contributing

1. Read [`SPEC.md`](SPEC.md) and [`CLAUDE.md`](CLAUDE.md).
2. Keep changes scoped to the current P0 slice.
3. Never add secrets, real credentials, private keys, or generated job data to Git.
4. Run the relevant lint, unit, containment, and deployment checks on the VM before claiming a
   slice is complete.
5. Do not weaken a sandbox limit or bypass a policy gate to make a test pass.

## License

ProofRun is released under the [MIT License](LICENSE).

## Acknowledgements

Built for the **lablab.ai VULTR Agent Rush hackathon**, with Vultr Serverless Inference as the
planned inference provider and Vultr Cloud Compute as the planned execution environment.
