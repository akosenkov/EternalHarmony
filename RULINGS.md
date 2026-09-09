# RULINGS.md — Project Institutional Memory

## Dead Ends (don't try these)

## Patterns (prefer these)

- In async tests, declare the handler before constructing the bus — avoid creating a bus just to discard it. `asyncio.coroutine` was removed in Python 3.11; use `async def` handlers always.

## Architecture Decisions

### AD-001: Mattermost bot account (not webhooks)
Use a bot account with the Mattermost API. Incoming/outgoing webhooks are stateless but
lack DM support, presence, and fine-grained permission control. Bot account enables richer
interaction patterns needed for decision threads and stakeholder DMs. Source: SPEC.md Open Questions.

### AD-002: Audience filtering via two sub-channels
Use separate channels per project: `#project-{name}` for internal (PO + devs) and
`#project-{name}-public` for customer-visible messages. Rationale: Mattermost has no
per-message visibility within a single channel; two channels is simplest and most reliable.
Bot posts public messages to `#project-{name}-public`, internal to `#project-{name}`.
Source: SPEC.md Open Questions option (b).

### AD-003: Cost ledger schema
Each bead's cost entry: `bead_id, title, agent, model, tokens, api_cost, infra_share,
external_api_cost, total, timestamp`. Written by agents to a shared ledger file; router
aggregates for reports. Implemented via OTel cost-exporter (comm-cr0/comm-710).

### AD-005: Platform-agnostic core — adapter pattern
Business logic (routing, scheduling, SLAs, detection) lives in `core/` and never imports
platform modules. Adapters (`adapters/mattermost.py`) implement `OutboundAdapter` /
`InboundAdapter` protocols. Swapping to Slack/Telegram = new adapter only. Source: ARCH.md.

### AD-006: Single binary, multi-project
One router process serves all projects. Per-project config from `specs/stakeholders.yml`.
Router watches for config changes (SIGHUP reload). Source: ARCH.md.

### AD-007: No LLM in router pipeline
Templates are pure functions: typed dataclass in, f-string out. No Jinja, no LLM.
Deterministic and auditable. Snapshot tests cover all templates. Source: ARCH.md.

### AD-008: Router state in SQLite (not agent systems)
Router maintains its own SQLite (`data/router.db`) with 7 tables:
`decisions`, `thread_map`, `stakeholder_activity`, `event_queue`, `weekly_metrics`,
`source_checkpoints` (GitSource/CostSource poll state), `stakeholder_preferences` (timezone inference).
Router never writes to Beads DB or Agent Mail (read-only on those). Source: ARCH.md.

### AD-009: In-process event bus (no external broker)
EventBus is async pub/sub running in-process. No Redis, no RabbitMQ. Events that can't
deliver go to `event_queue` table (bounded, 1000 messages) for degradation handling.
Source: ARCH.md.

### AD-010: Router exposes MCP server for agent-initiated posts
Agents post to stakeholder channels via MCP tools (`post_message`, `request_decision`,
`reply_to_thread`). Router validates authority, resolves logical channel to platform, delivers.
Agents never know which platform a stakeholder uses. Source: ARCH.md.

### AD-011: Intent detection is rule-based, not LLM
Inbound reply classification: numbered format ("1a", "1b", "yes", "approved", "done") = decision
reply → DecisionTracker.resolve(). Everything else = discussion → Agent Mail as-is.
Source: ARCH.md.

### AD-004: Portfolio briefing — per-project messages
At current scale (≤3 projects), post one message per project to `#portfolio`.
Revisit to consolidated message if/when ≥5 active projects. Source: SPEC.md Open Questions.

## Seam Warnings (integration gotchas)

### SW-013: Character-limit specs must account for realistic data density
Specifying "<2000 chars per section" is insufficient. With realistic agent names (13 chars), bead summaries (80 chars), and 20 entries, a compliance change_log section reached ~2179 chars. Future specs involving formatted output must derive the entry cap from: `floor(char_limit / (max_entry_size + overhead))`. Otherwise BlueBear will implement to the stated limit and GreenOwl will fail it on realistic data. (FEAT-001/trading-idea-13-19l)

### SW-001: Router is read-only on agent systems
The router MUST NOT write to Beads DB or Agent Mail. It only reads them and posts to
Mattermost. Human replies come back via webhook and are injected as Agent Mail messages —
this is the ONLY write path back into agent systems. Violation would create feedback loops.

### SW-002: Decision thread → Agent Mail mapping
Every Mattermost decision thread must carry its `thread_id` = `bd-###` in the message
metadata so the webhook handler can route human replies back to the correct Agent Mail
thread. If this mapping is lost, replies arrive as orphans and agents never unblock.

### SW-004: DecisionTracker must NOT duplicate router/inbound/scheduler logic
Decision CRUD already lives in StateStore (state.py). Router creates decision records;
inbound resolves them; scheduler emits DECISION_ESCALATED when SLA expires.
DecisionTracker (decisions.py) only implements: escalation chain advancement (update
current_level + assigned_to + sla_deadline in StateStore) and auto-decide (emit
DECISION_AUTO_RESOLVED). Do NOT re-implement create/resolve/sla-check in decisions.py.

### SW-005: Active-hours SLA: adjust deadline at creation, not at check time
`sla_deadline` stored in DB must reflect active hours (see comm-qio). Router._create_decision_record
computes deadline via `active_hours_deadline(now, sla_hours, active_start, active_end)` using
StateStore stakeholder_preferences. Fall back to wall-clock if preferences not yet inferred.
`_run_sla_check()` itself stays wall-clock (simple timestamp compare) — do NOT add active-hours
logic there. SW-005 originally deferred this; comm-qio implements it properly.

### SW-006: Gate multi-approver requires one decision record per approver
Budget gates may define `approver: [accountant, product_owner]`. One decision record
must be created per approver; the gate resolves only when ALL records are resolved.
Do NOT collapse multi-approver lists to a single record — each approver must independently
confirm. Implemented in `gates.py _emit_gate_pending` (comm-2j6).

### SW-007: Gate verification evidence must be passed in event data
SPEC.md: "Verification results and deterministic evidence (test output, ruff/ty results)
included in the thread — not just 'verified'." `GATE_PENDING` event data must include
`verification_output` and `tests_passed` (sourced from Beads bead metadata). Router gate
formatting displays them; use `"unavailable"` if absent — never omit the fields entirely.
Implemented in `gates.py _emit_gate_pending` and `router.py _format_for_importance` (comm-2j6).

### SW-010: Gate decisions require thread_map entry at emit time
_emit_gate_pending MUST set `event.data["thread_id"] = bead_id` so Router._send_and_map writes the
thread_map entry. Without it, InboundRouter.route() hits "no thread mapping" on every human reply
and gate decisions are unresolvable. Also set `agent_mail_thread_id = bead_id` on each decision
record. InboundRouter._handle_decision_reply must filter matched decisions by assigned_to ==
stakeholder_name to prevent one approver resolving another's record. (comm-zy5)

### SW-011: MCP server must be started in main.py, not just instantiated
RouterMCPTools must be started as an SSE/stdio transport in the asyncio.gather in main.py.
A tools object instantiated but not started is invisible to agents. The server must be part
of the lifecycle (start + graceful stop on SIGTERM). (comm-r9h)

### SW-012: Email fallback requires sync smtplib wrapped in run_in_executor
DegradationMonitor.send_email is a synchronous callable. In the async event loop, call it via
`loop.run_in_executor(None, send_email, to, subject, body)`. Direct call blocks the loop.
DegradationMonitor already catches exceptions — do not add extra try/except in the caller. (comm-7fj)

### SW-008: Scope filtering — events carry scope tag, router filters per stakeholder
`event.data["scope"]` carries a list of feature-area labels (e.g. `["F5"]`) sourced from bead labels.
Events without a scope tag match all stakeholders (wildcard). Stakeholders with `scope: "*"` receive
all events. Router._stakeholders_for_event() filters config.stakeholders before posting. (comm-tj9)
Do NOT hardcode channel names for scope routing — scope is stakeholder-config-driven.

### SW-009: Conflict resolution — higher authority wins immediately, never synthesise first
When two stakeholders reply to the same decision and they have different authority ranks, the higher
rank wins immediately without a synthesis step. Synthesis only applies to same-rank conflicts.
Authority rank: override(4) > decide(3) > decide_scoped(2) > flag_budget(1) > read(0).
All conflict resolutions must emit an AUDIT event. (comm-dny)

### SW-003: Gate bead close order
A checkpoint gate bead should only be closed AFTER the human approval is recorded.
Do not close it on verification pass alone — it must wait for the gate decision in
`#portfolio`/`#project-{name}`. Closing prematurely will unblock downstream work before
human sign-off.

### SW-016: Promptfoo eval YAML — bare arrays only, no transformVars
Promptfoo test files must use bare YAML arrays at the top level. Wrapping in a `tests:` key
causes an immediate parse error. The `transformVars` field (from other eval tools) is also
invalid — use `vars:` directly. Both mistakes caused 3-cycle verify bounces on comm-ku3/comm-7hs/comm-k30.
Lint YAML structure before handing off to GreenOwl: `npx promptfoo@latest eval --dry-run` locally first.

### SW-015: DetectionEngine wiring pattern
`check_drift()` is called from `_run_weekly_retro`; `check_stuck_agents()` runs hourly.
Both checks rely on live Mattermost reply counts — verify wiring survives any router refactor.

### SW-017: eval/tests/quality_scoring.yaml must be listed in promptfooconfig.yaml
The quality scoring test file exists and is documented in README.md but was not added to
the `tests:` array in `promptfooconfig.yaml` — full suite silently skipped all 3 tests.
Pattern: when adding a new test YAML to eval/tests/, always update promptfooconfig.yaml tests: list. (comm-si1)
