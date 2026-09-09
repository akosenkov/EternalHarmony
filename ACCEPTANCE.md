# Acceptance Criteria — harmony (minimal fib CLI)

Extracted from SPEC.md (Frozen: 2026-09-09). All criteria are machine-testable.
"exits 0" / "exits non-zero" refer to the process exit status.

1. `python main.py 0` prints `0` (single line on stdout) and exits 0.
2. `python main.py 1` prints `1` and exits 0.
3. `python main.py 10` prints `55` and exits 0.
4. `python main.py 100` prints `354224848179261915075` and exits 0 (arbitrary-precision correctness).
5. `python main.py 1000` completes in under 2 seconds and prints exactly `43466557686937456435688527675040625802564660517371780402481729089536555417949051890403879840079255169295922593080322634775209689623239873322471161642996440906533187938298969649928516003704476137795166849228875` (209 digits).
6. For every valid input, stdout stripped of whitespace matches the regex `^\d+$` (bare number, no extra text).
7. `python main.py` (no argument) exits non-zero and prints a usage message to stderr.
8. `python main.py abc` exits non-zero, prints an error to stderr, and writes nothing to stdout.
9. `python main.py -5` exits non-zero, prints an error to stderr, and writes nothing to stdout.
10. `pyproject.toml` still declares `dependencies = []` (no third-party packages added).
