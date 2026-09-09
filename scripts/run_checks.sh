#!/usr/bin/env bash
# Quality gate — delegates to the baked-in, version-controlled gate.
# Falls back to a minimal inline gate if the image predates stack-run-checks.
set -uo pipefail
if command -v stack-run-checks >/dev/null 2>&1; then
    exec stack-run-checks "$@"
fi
echo "stack-run-checks not on PATH — running minimal inline gate" >&2
FAIL=0
if command -v uv >/dev/null 2>&1 && uv run ruff --version >/dev/null 2>&1; then
    uv run ruff check . || FAIL=1
fi
if [ -d tests ] && [ -n "$(find tests -name '*.py' -print -quit 2>/dev/null)" ]; then
    uv run pytest tests/ --tb=short -q; rc=$?
    [ "$rc" -ne 0 ] && [ "$rc" -ne 5 ] && FAIL=1
fi
[ "$FAIL" -ne 0 ] && { echo "=== CHECKS FAILED ==="; exit 1; }
echo "=== All checks passed ==="
