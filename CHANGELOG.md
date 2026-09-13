# Changelog

## 1.2.0 - 2026-09-13
ClawHub security audit (1.1.0) — the two `unexpected` findings, both in `references/installation.md`:
- **Pinned the global install** (ClawScan T08 / `install_mechanism`). Step 1 offered `npm install -g hostinger-api-mcp` with no version, so every install and reinstall took whatever the registry served at that moment — into a process that then receives a token with full authority over the Hostinger account. All three package managers now pin `@1.8.2`, the same version `.mcp.json` already pinned for its `npx` launch, with the reason stated and instructions to bump both together. The section now leads with the `npx` route, which needs no global install at all. README's manual path pinned to match.
- **Token handling** (ClawScan T09 / `persistence_privilege`). The setup examples put the token literally on the command line (`-e HOSTINGER_API_TOKEN=YOUR_TOKEN`), which writes it to `~/.zsh_history` / `~/.bash_history` in plaintext and exposes it in `ps` while the command runs. A new "Handling the token safely" section covers the three exposures — shell history, the plaintext copy `claude mcp add -s user` leaves in `~/.claude.json` (which passing a variable does NOT avoid — it only keeps it out of the history), and the OAuth credential file at `~/.config/hostinger-mcp/credentials.json` — with `read -rs` for entry, `chmod 600` checks for both files, and revoke-and-regenerate in hPanel as the only recovery for an exposed token. Every example, single- and multi-account, now passes a variable. SKILL.md's credentials rule states the command-line prohibition so the agent follows it when setting a user up.

No tool, capability, or safety-rule changes.

## 1.1.0 - 2026-07-21
Zero-config connection for cloud sessions and devices:
- **Committed `.mcp.json`** (secrets as placeholders only) — launches `hostinger-api-mcp` via `npx` with the token from the `HOSTINGER_API_TOKEN` env var, so claude.ai cloud environments (which load the repo's `.mcp.json` from the clone and inject env vars from the environment config) and devices with the var in their shell get the tools with no per-machine setup. The `${HOSTINGER_API_TOKEN:-}` default keeps the config parseable when the var is unset — the connection then just shows as unavailable until the token is provided (a bare unset `${VAR}` would fail the whole config parse, per the Claude Code docs — Codex round-1 P1). Optional `HOSTINGER_MCP_BINARY` picks a category binary (e.g. `hostinger-vps-mcp`) to keep the tool surface lean.
- The `npx` launch is **version-pinned** (`hostinger-api-mcp@1.8.2`) — the config is auto-approved, so an unpinned latest would be a standing supply-chain risk; bump the pin deliberately.
- The CI **no-leak guard now scans the tracked `.mcp.json` / `.mcp.json.example`** (Codex round-1 P1) so a real token pasted into them can't pass CI. Exemptions apply to placeholder **values** only — not the key name or the `example` filename (Codex round-2 P1) — and a JSON-parsing check validates the actual env/header values independent of line layout, closing the split-across-lines evasion (Codex round-3 P1).
- `.mcp.json` removed from `.gitignore` (the tracked file must never contain a real token); `.mcp.json.example` re-purposed as the multi-account/per-category reference shape — real tokens go to user scope (`claude mcp add -s user`) or env vars, never into the tracked file.
- `.claude/settings.json` sets `enableAllProjectMcpServers` so the committed config is auto-approved once the folder is trusted — untrusted checkouts deliberately ignore the committed key (v2.1.196+) and prompt once.
- installation.md + README document the env-var route (README now separates it from the manual `npm i -g` path) and the migration off a local gitignored `.mcp.json`. Node note: upstream states v24+; verified working on Node 22.

## 1.0.1 - 2026-07-03
- Codex review: `billing_enableAutoRenewalV1` promoted to W! (money-spending) to match the SKILL safety rule; W/W! totals corrected.

## 1.0.0 - 2026-06-04
- First public cut: skill wrapping the official Hostinger MCP server (hostinger/api-mcp-server). Category-binary tool loading, full 127-tool catalog (6 categories / 7 binaries, 51 R / 55 W / 21 W!), VPS workflow playbook, multi-account (token per connection), write/cost-confirmation safety. Kit-standard packaging (CI + ClawHub publish workflow, no-leak guard).
