# Installation — Hostinger MCP Server

This skill targets the **official Hostinger MCP** — a local npm server (`hostinger-api-mcp`) that you run on your own machine and connect Claude to over stdio (or HTTP).

> **Source of truth:** [github.com/hostinger/api-mcp-server](https://github.com/hostinger/api-mcp-server). The package name, binaries, flags, and auth below are from that repo; if Hostinger changes them, the repo wins.

**Prerequisites**

- A Hostinger account with an **API token** generated in [hPanel](https://hpanel.hostinger.com).
- **Node.js v24+** (the server requires it).

---

## Step 1 — Install

**Preferred: do not install it globally at all.** The repo's committed `.mcp.json` launches the
server with `npx -y -p hostinger-api-mcp@1.8.2` — a pinned version, resolved per run, nothing
added to your PATH. If you use that route (Step 4), skip this step.

If you do want the category binaries on your PATH, **pin the version**:

```bash
npm install -g hostinger-api-mcp@1.8.2
# or
yarn global add hostinger-api-mcp@1.8.2
# or
pnpm add -g hostinger-api-mcp@1.8.2
```

> **Why pinned.** This process receives a token with **full authority over your Hostinger
> account** (Step 2). An unpinned install takes whatever the registry serves at that moment, on
> every install and every reinstall — so a hijacked or compromised release of the package, or of
> anything in its dependency tree, inherits that authority with no action on your part. Keep the
> pin equal to the one in `.mcp.json` and bump both together, after reading the upstream release
> notes at [github.com/hostinger/api-mcp-server](https://github.com/hostinger/api-mcp-server).

This installs the category binaries (see Step 3).

---

## Step 2 — Get the API token

1. Log in to [hPanel](https://hpanel.hostinger.com).
2. Open **API** and generate a token.
3. Copy the token.

The server sends it as a Bearer `Authorization` header. Set it in the `HOSTINGER_API_TOKEN` environment variable.

> The token grants everything the account can do via the API. Treat it like a password — never commit it or print it in responses.

**OAuth alternative (stdio only).** Instead of a token you can authenticate interactively with OAuth 2.0 + PKCE:

```bash
hostinger-api-mcp --login    # opens a browser flow
hostinger-api-mcp --logout   # clears stored credentials
```

Credentials are stored at `~/.config/hostinger-mcp/credentials.json` as a **single central credential per machine**. Because OAuth can store only one credential, it **cannot separate accounts** — for multi-account use, prefer API tokens (see below).

### Handling the token safely

The token is equivalent to your hPanel password, and there is no per-tool permission at the MCP
layer — whoever holds it can call anything. Three places it leaks by default:

**1. Your shell history.** A token typed literally into a command (`-e HOSTINGER_API_TOKEN=hst_…`)
is written to `~/.zsh_history` / `~/.bash_history` in plaintext, and is visible in `ps` output to
every other user on the machine for as long as the command runs. Read it into a variable instead,
and pass the variable:

```bash
printf 'Hostinger API token: '
read -rs HOSTINGER_API_TOKEN; echo
export HOSTINGER_API_TOKEN
```

`read -rs` does not echo the token and the assignment never reaches the history file. Use
`$HOSTINGER_API_TOKEN` in every command below.

**2. The persisted client config.** `claude mcp add -s user` stores what you pass it as
**plaintext** in `~/.claude.json` — expanding a variable does not change that, it only keeps the
value out of your history. Two consequences: check the file is not group/world readable
(`ls -l ~/.claude.json`, then `chmod 600 ~/.claude.json`), and prefer the env-var route in Step 4,
which keeps the token out of any config file entirely.

**3. The OAuth credential file.** `~/.config/hostinger-mcp/credentials.json` holds a live
credential written by the upstream package. Verify its mode (`ls -l`) and tighten it if needed
(`chmod 600`), and run `hostinger-api-mcp --logout` before leaving a shared or handed-over machine.

If a token may have been exposed — pasted into a chat, committed, left in a history file on a
shared box — **revoke and regenerate it in hPanel**. There is no narrower recovery: the token
carries the whole account.

---

## Step 3 — Pick category binaries

The package ships seven binaries. Each exposes a subset of the 127 tools. Connect only the **smallest set** that covers your task — fewer tools keeps Claude's context lean and tool selection accurate.

| Binary | Tools | Use for |
|--------|-------|---------|
| `hostinger-vps-mcp` | 62 | VPS lifecycle, firewalls, snapshots, backups, public keys, post-install scripts |
| `hostinger-hosting-mcp` | 22 | shared hosting websites, subdomains, parked domains, databases, deployments |
| `hostinger-domains-mcp` | 18 | domain registration, forwarding, WHOIS profiles, locks, privacy, nameservers |
| `hostinger-reach-mcp` | 10 | Reach contacts, segments, groups, profiles |
| `hostinger-dns-mcp` | 8 | DNS records and snapshots |
| `hostinger-billing-mcp` | 7 | subscriptions, payment methods, catalog, auto-renewal |
| `hostinger-api-mcp` | all 127 | everything (only when you genuinely need broad coverage) |

---

## Step 4 — Connect Claude Code (stdio)

### Env var (zero-config — devices and cloud sessions)

The repo commits a `.mcp.json` that launches the server via `npx` (version-pinned) and reads
the `${HOSTINGER_API_TOKEN:-}` env placeholder — never a real token. Set that variable — in
your shell profile on a device, or in the claude.ai cloud environment's environment variables
for web/phone sessions — and the `hostinger` connection authenticates automatically. While
the variable is unset the config still parses (the `:-` default), but calls fail auth and the
connection shows as unavailable in `/mcp` — expected until you provide the token. By default
it loads the full `hostinger-api-mcp` (all 127 tools); set `HOSTINGER_MCP_BINARY` to a category
binary (e.g. `hostinger-vps-mcp`) to keep the tool surface lean. Never put a real token in
`.mcp.json` itself; it is tracked in git. Cloud environments with a restricted network policy
must allow the npm registry (for `npx`) and the Hostinger API.

### Per-category user-scope connections (for multi-category or multi-account work)

stdio is the default transport. Add one connection per binary you need. Example for the VPS binary,
with the token already in your environment (Step 2 — never type it into the command):

```bash
claude mcp add --transport stdio \
  -e HOSTINGER_API_TOKEN="$HOSTINGER_API_TOKEN" \
  -s user \
  hostinger-vps hostinger-vps-mcp
```

> **This writes the token in plaintext to `~/.claude.json`** and leaves it there until you remove
> the connection. That is the trade for per-connection tokens; the env-var route above avoids it.
> Check the file's mode after the first `claude mcp add` (`chmod 600 ~/.claude.json`).

`-s user` stores it at the user level so it persists across projects. Repeat with a different name + binary for each category you need (e.g. `hostinger-dns hostinger-dns-mcp`).

> Verify the exact env-flag for `claude mcp add` in your Claude Code version with `claude mcp add --help` (it has varied across releases). The canonical config shape is in `.mcp.json.example` at the repo root.

After `claude mcp add`, **restart Claude Code** so the stdio server is launched and its tools load. Verify with `claude mcp list`; remove later with `claude mcp remove hostinger-vps`.

---

## Multi-account — multiple Hostinger accounts

Use **one connection per account**, each with its own `HOSTINGER_API_TOKEN`. Name them `hostinger-<account>` (or `hostinger-<account>-<category>` if you also split by binary) so the tool prefix tells you which account you're on:

Read each account's token into a variable first (Step 2), one at a time, so neither reaches your
shell history:

```bash
printf 'Client A token: '; read -rs TOKEN_A; echo
claude mcp add --transport stdio \
  -e HOSTINGER_API_TOKEN="$TOKEN_A" \
  -s user \
  hostinger-clienta-vps hostinger-vps-mcp

printf 'Client B token: '; read -rs TOKEN_B; echo
claude mcp add --transport stdio \
  -e HOSTINGER_API_TOKEN="$TOKEN_B" \
  -s user \
  hostinger-clientb-vps hostinger-vps-mcp

unset TOKEN_A TOKEN_B
```

> Each of these lands in `~/.claude.json` in plaintext — one entry per account. Keep that file at
> mode 600, and `claude mcp remove` a connection when the engagement ends rather than leaving a
> live token behind.

> **Use API tokens for multi-account.** OAuth stores ONE central credential per machine and cannot separate accounts — only env-scoped tokens can. See `.mcp.json.example` in the repo root for the JSON form across accounts.

---

## HTTP mode (optional)

To run over HTTP instead of stdio:

```bash
hostinger-api-mcp --http --host 127.0.0.1 --port 8100
```

The API token (`HOSTINGER_API_TOKEN`) is **required** in HTTP mode. OAuth is **not supported** over HTTP — it works in stdio mode only.

---

## Verify the connection

In Claude, ask:

- **"List my Hostinger VPS"** → calls `VPS_getVirtualMachinesV1`, or
- **"List my domains"** → calls `domains_getDomainListV1`.

That round-trip confirms the install + token.

| Symptom | Meaning | Fix |
|---------|---------|-----|
| No `mcp__hostinger*__*` tools | stdio server not loaded | restart Claude Code |
| `401 Unauthorized` | bad or missing token | re-check `HOSTINGER_API_TOKEN` against the token in hPanel |
| Node engine / version error | Node too old | install Node.js v24+ |

---

## Notes

- API reference: <https://developers.hostinger.com/>
- Tool names throughout this skill use the `Category_actionVn` convention and match `tools-catalog.md`. In Claude they appear as `mcp__<connection-name>__<tool>`. The **live** tools remain the source of truth if Hostinger adds or renames any.
