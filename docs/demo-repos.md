# ProofRun Demo Repositories

The following permissively licensed repositories are used for public verification demonstrations:

1. **Clean Web Application (F1):**
   - Source: Built-in fixture (`fixtures/clean`)
   - Stack: FastAPI + Vanilla JS
   - Expected Tier: 🟢 VERIFIED

2. **Self-Healing Environment Recovery (F2):**
   - Source: Built-in fixture (`fixtures/broken-env`)
   - Stack: Flask
   - Expected Tier: 🔵 RUNS_AFTER_FIX

3. **Vaporware / Claim Mismatch (F3):**
   - Source: Built-in fixture (`fixtures/vaporware`)
   - Stack: Python HTTP
   - Expected Tier: 🟡 CLAIM_MISMATCH

4. **Blast Radius Zero Detonation (F4):**
   - Source: Built-in fixture (`fixtures/evil-submission`)
   - Attack vectors: Prompt injection, curl pipe sh, canaries exfil, metadata probe, fork loop, disk exhaustion
   - Expected Tier: 🔴 QUARANTINED
