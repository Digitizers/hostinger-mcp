# Changelog

## 1.1.0 - 2026-07-21
Zero-config connection for cloud sessions and devices:
- **Committed `.mcp.json`** (placeholders only) — launches `hostinger-api-mcp` via `npx` with the token from the `HOSTINGER_API_TOKEN` env var, so claude.ai cloud environments (which load the repo's `.mcp.json` from the clone and inject env vars from the environment config) and devices with the var in their shell get the tools with no per-machine setup. Unset var → server skipped silently. Optional `HOSTINGER_MCP_BINARY` picks a category binary (e.g. `hostinger-vps-mcp`) to keep the tool surface lean.
- `.mcp.json` removed from `.gitignore` (the tracked file must only ever contain `${VAR}` placeholders); `.mcp.json.example` re-purposed as the multi-account/per-category reference shape — real tokens go to user scope (`claude mcp add -s user`) or env vars, never into the tracked file.
- `.claude/settings.json` sets `enableAllProjectMcpServers` so the committed config is auto-approved.
- installation.md + README document the env-var route and the migration off a local gitignored `.mcp.json`.

## 1.0.1 - 2026-07-03
- Codex review: `billing_enableAutoRenewalV1` promoted to W! (money-spending) to match the SKILL safety rule; W/W! totals corrected.

## 1.0.0 - 2026-06-04
- First public cut: skill wrapping the official Hostinger MCP server (hostinger/api-mcp-server). Category-binary tool loading, full 127-tool catalog (6 categories / 7 binaries, 51 R / 55 W / 21 W!), VPS workflow playbook, multi-account (token per connection), write/cost-confirmation safety. Kit-standard packaging (CI + ClawHub publish workflow, no-leak guard).
