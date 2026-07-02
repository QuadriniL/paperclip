# Upstream cherry-pick backlog (BizCursor fork)

Fork base: [QuadriniL/paperclip](https://github.com/QuadriniL/paperclip)  
Upstream: [paperclipai/paperclip](https://github.com/paperclipai/paperclip)

## Wave 1 — merged in PR #3 (`bizcursor/upstream-wave-1`)

| PR | Title | Scope | Chat-mode impact |
|----|-------|-------|------------------|
| [#4734](https://github.com/paperclipai/paperclip/pull/4734) | Strip JWT signing secrets from spawned agent env | `adapter-utils` | None — server keeps secrets; child processes never see them |
| [#7292](https://github.com/paperclipai/paperclip/pull/7292) | Remove `OPENCODE_DISABLE_PROJECT_CONFIG` | `opencode-local` | None — allows project `opencode.json` for custom providers |
| [#8075](https://github.com/paperclipai/paperclip/pull/8075) | Parse runtime config as JSONC | `opencode-local` | None — preserves custom providers in JSONC configs |
| [#6766](https://github.com/paperclipai/paperclip/pull/6766) | `opencode export` fallback when stdout empty | `opencode-local` | None — improves response capture on OpenCode v1.15.10+ |
| [#6821](https://github.com/paperclipai/paperclip/pull/6821) | Propagate `issue.billing_code` to cost-events | `heartbeat.ts` | **Preserved** — chat-mode still uses `bizcursor:{threadId}`; issue billing code applies to issue-centric runs only |

## Wave 2 — deferred (heartbeat / high conflict)

| PR | Title | Why deferred |
|----|-------|--------------|
| [#8835](https://github.com/paperclipai/paperclip/pull/8835) | Billing-limit non-retryable + session reset | Conflicts with fork `heartbeat.ts` (chat-mode, context pack) |
| [#8776](https://github.com/paperclipai/paperclip/pull/8776) | False `process_lost` detection | Touches heartbeat recovery paths |
| [#8814](https://github.com/paperclipai/paperclip/pull/8814) | Heartbeat scheduling | Merge after rebase |
| [#8813](https://github.com/paperclipai/paperclip/pull/8813) | Heartbeat queue | Merge after rebase |
| [#6650](https://github.com/paperclipai/paperclip/pull/6650) | Cold-wake briefing | Touches wake prompt assembly |
| [#7717](https://github.com/paperclipai/paperclip/pull/7717) | Think variant | Conflicts with fork think-variant patch |

## Out of scope for BizCursor dual-adapter

- `cursor_cloud` chat-mode — not used (issue-centric Dev path only)
- Full upstream rebase (~177 commits behind) — separate effort
- `costUsd` pricing for Cursor models — blocked on upstream pricing catalog

## Merge policy

When cherry-picking into `heartbeat.ts`:

1. **Chat-mode billing** (`bizcursor:{threadId}`) wins over issue `billing_code` when `chatThreadId` is present.
2. Do not remove fork patches: chat wake, context pack, think variant, session payload branch.
3. Run tests: `pnpm exec vitest run packages/adapters/cursor-cloud packages/adapters/opencode-local packages/adapter-utils`
