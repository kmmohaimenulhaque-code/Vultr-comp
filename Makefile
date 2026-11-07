.PHONY: install test smoke showroom keygen clean

install:
	python -m pip install -e ".[dev]"

test:
	python tests/run_tests.py

smoke:
	python scripts/smoke_inference.py

showroom:
	python scripts/record_showroom.py

keygen:
	python scripts/keygen.py

clean:
	find . -type d -name __pycache__ -exec rm -rf {} + 2>/dev/null || true
	rm -rf .pytest_cache .mypy_cache *.egg-info dist build
