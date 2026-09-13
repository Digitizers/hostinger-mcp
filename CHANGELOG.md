# Changelog

## 1.2.1 - 2026-09-13

From the ClawHub audit of 1.2.0. T08 and T09 are gone; ClawScan's remaining
`install_mechanism` concern — and AIG's High — is that the reviewed artifact pins a version
but carries "no vendored implementation, lockfile, or hash".

- **The pinned version now has a recorded integrity digest, checked BEFORE the install.**
  Installing an npm package runs its `preinstall` / `install` / `postinstall` scripts, so a
  digest printed for the user to eyeball after `npm install -g` is a report, not a control —
  altered code has already executed. `installation.md` now fetches with `npm pack` (which
  installs nothing), compares against the recorded `sha512` and **exits non-zero on a
  mismatch with nothing installed**, then installs from that verified local tarball rather
  than fetching again. The install also exits non-zero when `npm install`
  fails, rather than being rescued by a successful cleanup. The `npx` route in `.mcp.json` is
  pinned but cannot be verified — it fetches and executes in one step, every run — and that
  trade is now stated where the route is offered, in `installation.md` **and in the README**,
  with the verified alternative beside it: the README no longer offers a bare `npm i -g` of
  its own. Recording the digest **here** is what
  makes the check worth running: npm forbids republishing a version with different content, so a value
  held out of band catches a registry that later serves different bytes for 1.8.2. Comparing
  against `npm view … dist.integrity` instead proves much less — that digest travels from the
  same registry as the tarball, so it is integrity, not provenance, the same distinction the
  `EMCP_EXPECTED_SHA256` note makes in our Elementor kit. Neither check covers the dependency
  tree, and the text says so. Bumping the pin means recording the new digest in the same
  commit.

The other remaining `concern`, `Credentials`, is that `HOSTINGER_API_TOKEN` carries full
account authority with no per-tool permission at the MCP layer. That is a property of
Hostinger's API, not of this skill: there is no narrower token to ask for. It is disclosed in
SKILL.md, in the audit's own words ("disclosed and aligned with the MCP integration"), and
the category binaries reduce the tool surface an agent sees even though they cannot reduce
the token's authority.

## 1.2.0 - 2026-09-13
ClawHub security audit (1.1.0) — the two `unexpected` findings, both in `references/installation.md`:
- **Pinned the global install** (ClawScan T08 / `install_mechanism`). Step 1 offered `npm install -g hostinger-api-mcp` with no version, so every install and reinstall took whatever the registry served at that moment — into a process that then receives a token with full authority over the Hostinger account. All three package managers now pin `@1.8.2`, the same version `.mcp.json` already pinned for its `npx` launch, with the reason stated and instructions to bump both together. The section now leads with the `npx` route, which needs no global install at all. README's manual path pinned to match.
- **Token handling** (ClawScan T09 / `persistence_privilege`). The setup examples put the token literally on the command line (`-e HOSTINGER_API_TOKEN=YOUR_TOKEN`), exposing it three ways: the shell history file, `ps` / `/proc/<pid>/cmdline` for every other user on the machine while the command runs, and the resolved value `claude mcp add -s user` then stores in `~/.claude.json` in plaintext until the connection is removed. Every example now passes a **quoted placeholder** — `-e 'HOSTINGER_API_TOKEN=${HOSTINGER_API_TOKEN:-}'` — which closes all three at once: the shell never expands it, so neither the argument list nor the stored config holds the secret, and Claude Code expands it from its own environment when it launches the server (verified: expansion runs on local- and user-scoped `~/.claude.json` entries too, not only a project `.mcp.json` — an unset reference produces a `Missing environment variables` warning in `claude mcp list`). Multi-account uses one variable NAME per account with the same placeholder mechanism. The new "Handling the token safely" section adds where the value should live (`read -rs` for a session, a mode-600 profile or a keychain lookup for a persistent setup, cloud env vars), the OAuth credential file at `~/.config/hostinger-mcp/credentials.json`, and revoke-and-regenerate in hPanel as the only recovery for an exposed token — checked with a **presence** test that parses `~/.claude.json` with `node` and prints connection names only — never the value, since a leak-hunting command that echoes its match puts a possibly still-live credential into the scrollback, and never a line-based `grep`, which JSON can evade by putting the value on the line after its key (the same evasion this repo's CI no-leak guard grew a JSON-parsing pass for in 1.1.0). The test counts literal material inside `:-` defaults as well as outside the placeholders, so `${HOSTINGER_API_TOKEN:-hst_live}` — still plaintext in the file, and still what the server receives whenever the variable is unset — is reported rather than waved through for merely containing `${`, and a value split across several defaults with it; that is the same rule the CI guard applies to the tracked MCP configs. `.mcp.json.example` — the multi-account JSON shape installation.md points at — carries the same placeholders rather than `ACCT_A_TOKEN`-style literals, so following the example cannot produce the plaintext file the section above promises to avoid. SKILL.md's credentials rule states the prohibition so the agent follows it when it is the one setting a user up.

README version badge bumped to match.

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
