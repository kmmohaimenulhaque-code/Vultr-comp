# ProofRun Automation Targets

.PHONY: setup image lint test test-firewall pod-hello test-containment smoke-inference dev showdown showroom check-secrets

setup:
	python3 -m venv .venv && .venv/bin/pip install -e .

image:
	docker build -t proofrun-sandbox:latest -f sandbox/Dockerfile .

lint:
	ruff check .

test:
	PYTHONPATH=. python3 tests/run_tests.py

test-firewall:
	bash deploy/firewall.sh

pod-hello:
	PYTHONPATH=. python3 scripts/smoke_inference.py

test-containment:
	PYTHONPATH=. python3 -c "import asyncio; from orchestrator.jobs import JobRunner; asyncio.run(JobRunner('test-evil', {'kind': 'fixture', 'fixture': 'evil-submission'}).run())"

smoke-inference:
	PYTHONPATH=. python3 scripts/smoke_inference.py

dev:
	PYTHONPATH=. uvicorn orchestrator.main:app --host 127.0.0.1 --port 8000 --reload

showdown:
	PYTHONPATH=. python3 -m orchestrator.cli showdown

showroom:
	PYTHONPATH=. python3 scripts/record_showroom.py

check-secrets:
	PYTHONPATH=. python3 scripts/check_secrets.py
