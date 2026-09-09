# Project Specification

*Frozen: 2026-09-09*

## Overview

**harmony** is a canary project: a deliberately minimal command-line Fibonacci
calculator. Its purpose is to prove the end-to-end delivery pipeline
(spec → beads → execution → verification → release) works on this stack.

**Project name:** harmony
**Status:** Planning
**Owner:** alex.kosenkov

## Goals

1. `python main.py <n>` prints the nth Fibonacci number (0-indexed: fib(0)=0, fib(1)=1).
2. Correct for large n — Python arbitrary-precision integers, no overflow.
3. Invalid input produces a short error on stderr and a non-zero exit code.

## Non-goals

- No web UI, HTTP API, or any network interface — CLI only.
- No third-party dependencies — Python standard library only.
- No performance work beyond a simple iterative O(n) algorithm (no fast doubling, no matrix exponentiation, no memoization).
- No sequence printing — output is a single number, not the series.
- No negative-index Fibonacci (nega-fib).
- No packaging or distribution (no PyPI, no installer); runs in place via `python main.py`.

## Users & Personas

| Persona | Needs | Pain points |
|---------|-------|-------------|
| Operator (stakeholder) | Run `python main.py <n>` and read one number | Any setup beyond a Python ≥3.13 interpreter |

## Features & Requirements

### P0 — Must have (MVP)

- [ ] CLI Fibonacci calculator: `python main.py N` prints fib(N) for any non-negative integer N and exits 0. stdout is the bare decimal number plus a trailing newline — nothing else. Invalid input (missing argument, non-integer, negative) prints a short usage/error message to stderr and exits non-zero.

### P1 — Should have

- (none — canary scope is deliberately P0-only)

### P2 — Nice to have

- (none)

## Architecture

Single module: `main.py` at the repository root. Stdlib only (`sys` for argv).
Iterative O(n) loop using Python's native arbitrary-precision integers.
Checks run via the existing `scripts/run_checks.sh` harness (ruff + pytest).

## Constraints

- Python ≥ 3.13 (`pyproject.toml`; `.python-version` pins 3.14).
- Zero third-party dependencies: `pyproject.toml` `dependencies` must remain `[]`.

## External Dependencies

None.

## Acceptance Criteria

See `ACCEPTANCE.md` (extracted verbatim from this spec).
