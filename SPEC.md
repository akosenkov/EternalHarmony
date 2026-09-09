# Project Specification

> Fill this out before starting development. Agents read this for context.
> Delete the instructional comments (lines starting with >) once filled in.

## Overview

> One paragraph: what is this project and why does it exist?

**Project name:** eternalharmony
**Status:** Planning | In Progress | MVP | Production
**Owner:** <!-- PM or tech lead name/handle -->

## Goals

> What does success look like? List 3-5 measurable outcomes.

1. <!-- e.g., "Users can sign up, log in, and manage their profile" -->
2.
3.

## Non-goals

> What is explicitly out of scope? Helps agents avoid gold-plating.

- <!-- e.g., "Mobile app — web only for MVP" -->
-

## Users & Personas

> Who uses this? What do they care about?

| Persona | Needs | Pain points |
|---------|-------|-------------|
| <!-- e.g., "Data analyst" --> | <!-- "Fast search across datasets" --> | <!-- "Current tool is slow, no API" --> |

## Features & Requirements

> Ordered by priority. Agents will work top-down unless told otherwise.

### P0 — Must have (MVP)

- [ ] <!-- e.g., "REST API with /search endpoint returning paginated results" -->
- [ ]

### P1 — Should have

- [ ]
- [ ]

### P2 — Nice to have

- [ ]
- [ ]

## Architecture

> High-level system design. Agents use this to understand where code lives.

**Stack:**
- Language: Python 3.13
- Framework: <!-- e.g., FastAPI, Django, Flask -->
- Database: <!-- e.g., PostgreSQL, SQLite, none -->
- Frontend: <!-- e.g., HTMX + Jinja2, React, none -->
- Deployment: <!-- e.g., Docker, AWS Lambda, bare metal -->

**Module layout:**
```
app/              # Application code
  api/            # API routes/endpoints
  core/           # Business logic
  models/         # Data models
config/           # Configuration files
scripts/          # Utility scripts
tests/            # Test suite
web/              # Frontend (if applicable)
docs/             # Documentation
```

> Adjust the tree above to match your actual or intended layout.

## Constraints & Decisions

> Technical constraints agents must respect. Add rationale so agents don't revisit settled decisions.

- <!-- e.g., "Use pyvips not Pillow for image processing — Pillow is too slow for large tiles" -->
- <!-- e.g., "All config via python-decouple from .env — no os.getenv scattered in code" -->
- <!-- e.g., "SQLite for MVP, migrate to PostgreSQL later — keep queries compatible" -->

## External Dependencies & APIs

> Services, APIs, or data sources this project integrates with.

| Dependency | Purpose | Auth method | Docs |
|-----------|---------|-------------|------|
| <!-- e.g., "Stripe API" --> | <!-- "Payment processing" --> | <!-- "API key in .env" --> | <!-- "https://stripe.com/docs" --> |

## Quality & Acceptance Criteria

> How do we know a feature is done?

- [ ] Tests pass (`./scripts/run_checks.sh`)
- [ ] No ruff lint errors
- [ ] Type checks pass (ty)
- [ ] Works in Docker (`./claude-docker/claude-env.sh shell`)
- <!-- Add project-specific criteria -->

## Agent Coordination Notes

> Guidance for multi-agent workflows via Agent Mail.

**File ownership hints:**
> Which areas are likely to conflict? Agents should reserve these before editing.

| Area | Glob pattern | Notes |
|------|-------------|-------|
| <!-- e.g., "API routes" --> | <!-- "app/api/**" --> | <!-- "High contention — always reserve" --> |
| <!-- e.g., "Database models" --> | <!-- "app/models/**" --> | <!-- "Schema changes need coordination" --> |

**Coordination thread IDs:**
> Suggested thread ID conventions for Agent Mail.

- Features: `FEAT-<number>` (e.g., `FEAT-1`)
- Bugs: `BUG-<number>`
- Infra: `INFRA-<number>`

## Open Questions

> Unresolved decisions. Agents should flag these, not guess.

- [ ] <!-- e.g., "Which OAuth provider? Google, GitHub, or both?" -->
- [ ]

---

*Last updated: <!-- date -->*
