# Hostinger MCP — Claude Code & OpenClaw Skill

[![CI](https://github.com/Digitizers/hostinger-mcp/actions/workflows/ci.yml/badge.svg)](https://github.com/Digitizers/hostinger-mcp/actions/workflows/ci.yml)
![Claude Code Skill](https://img.shields.io/badge/Claude_Code-Skill-d97757)
![OpenClaw Skill](https://img.shields.io/badge/OpenClaw-Skill-purple)
![Hostinger](https://img.shields.io/badge/Hostinger-MCP-673de6)
![License: MIT](https://img.shields.io/badge/License-MIT-green)
![Version](https://img.shields.io/badge/version-1.1.0-blue)

A production-grade **Claude Code & OpenClaw skill** for managing [Hostinger](https://digitizer.li/hostinger) infrastructure — VPS, websites, domains, DNS, email (Reach), and billing — through the official **Hostinger MCP server**, across one or many accounts, with a safety rule on every write.

This is not just a tool reference. It is an operational playbook for running Hostinger responsibly: category-scoped tool loading (so you never drown in 127 tools at once), VPS provisioning and lifecycle, domain/DNS changes, and money-spending guardrails — with write-confirmation on anything that changes state or costs money.

## Part of the Aura Design Engine

These are the free skills behind [**Aura**](https://my-aura.app) — one AI web-agency lifecycle you can run standalone or orchestrate across a whole client fleet from a single dashboard.

| Stage | Skill | Role |
| --- | --- | --- |
| 🎨 Build | [siteagent-elementor-studio](https://github.com/Digitizers/siteagent-elementor-studio) | Design & build sites inside Elementor |
| 🔎 Audit + Content | [wordpress-api-pro](https://github.com/Digitizers/wordpress-api-pro) | REST content ops, SEO & site audits |
| 🖥 Host | [cloudways-mcp](https://github.com/Digitizers/cloudways-mcp) · [**hostinger-mcp** ← you are here](https://github.com/Digitizers/hostinger-mcp) | Provision & operate the infrastructure |

**→ Orchestrate all of it across your client fleet with [Aura](https://my-aura.app)** — governed agent ops with approvals and a full audit trail on top of these skills.

## Solo, or with Aura

This skill works standalone — point it at your own Hostinger account and run it from Claude Code. That's the **solo path**: you drive one account, and the write-confirmation guardrail on anything that changes state or costs money keeps you safe.

The **Aura path** is the same skill orchestrated across a whole client fleet — [Aura](https://my-aura.app) proxies these provider ops through its governed MCP gateway, adds queued human approvals and a full audit trail, and runs them across every VPS and site you manage from one dashboard, no per-account token juggling.

| | Solo (this skill) | With Aura |
| --- | --- | --- |
| Scope | one account you hold keys for | every client account in your org |
| Approvals | your own write-confirmation | queued admin approval + audit trail |
| Best for | your own infra, quick ops | agencies operating many clients |

Use it solo for your own boxes; reach for Aura when you operate a fleet on clients' behalf.

## Features

- ✅ **Official Hostinger MCP** — the npm `hostinger-api-mcp` server (Node 24+), stdio or HTTP.
- ✅ **Category-binary loading** — connect only `hostinger-vps-mcp` / `hostinger-dns-mcp` / … instead of all 127 tools; keep context lean.
- ✅ **Full tool catalog** — 127 tools across VPS, hosting, domains, DNS, Reach, and billing, tagged R / W / W!.
- ✅ **Write- and cost-confirmation safety** — state-changing and money-spending operations require explicit, account-scoped confirmation; destructive ops double-confirm.
- ✅ **Multi-account** — one connection per account/token, each with its own prefix; no cross-account mixing.
- ✅ **VPS playbook** — provision, lifecycle, firewall, recreate/snapshots, projects.

## Structure

```text
.claude/skills/hostinger-mcp/
├── SKILL.md                       # core: category-binary loading, safety, multi-account, auth
└── references/
    ├── installation.md            # npm install, token, 7 binaries, Claude config, multi-account
    ├── tools-catalog.md           # all 127 tools, 6 categories / 7 binaries, R / W / W!
    └── workflows-vps.md           # flagship VPS playbook
```

## Activation

The skill activates when Hostinger is discussed and a `hostinger*` MCP server is connected — the committed config's `hostinger`, or per-category names like `hostinger-vps` (tools appear as `mcp__hostinger*__*`). Two setup paths — pick one:

**Zero-config connection via env var (recommended).** The repo commits a [`.mcp.json`](.mcp.json) that launches `hostinger-api-mcp` through `npx` (version-pinned, no global install needed) with the token from the `${HOSTINGER_API_TOKEN:-}` env placeholder — set the variable in your shell (devices) or in the claude.ai cloud environment's env vars (web/phone sessions) and the connection authenticates on its own. While the variable is unset the connection just shows as unavailable in `/mcp` (it can't authenticate) — set the var to bring it up. Set `HOSTINGER_MCP_BINARY` (e.g. `hostinger-vps-mcp`) to load a single category binary instead of all 127 tools. Real tokens never go into the file — it is tracked in git. **Migrating from a local gitignored `.mcp.json`:** move your token to the env var (or `claude mcp add -s user`), delete the local file, then pull.

**Manual per-category connections.** Install with `npm i -g hostinger-api-mcp` and wire user-scope connections per category/account with `claude mcp add -s user` — see [`installation.md`](.claude/skills/hostinger-mcp/references/installation.md) and [`.mcp.json.example`](.mcp.json.example).

## Sources

- [hostinger/api-mcp-server](https://github.com/hostinger/api-mcp-server) (official MCP server)
- [Hostinger API docs](https://developers.hostinger.com/)

## Links

- **Repository:** https://github.com/Digitizers/hostinger-mcp
- **OpenClaw:** https://openclaw.ai
- **Hostinger:** https://www.hostinger.com/
- **Digitizer:** https://www.digitizer.studio

## License

MIT

---

Built with ❤️ for OpenClaw by [Digitizer](https://www.digitizer.studio)

### Windows note

The plugin ships its skill through a git **symlink** (`skills/` → the in-repo
source). On Windows, enable Developer Mode and set
`git config --global core.symlinks true` **before** cloning or installing —
the plugin cache clone inherits it. Changing the config does not repair an
existing checkout (the repo may have recorded `core.symlinks=false` locally).
To repair one, run these two commands inside it (the second re-materializes
only the plugin's symlink entry, so nothing else in your working tree is
touched):

    git config core.symlinks true
    git checkout -- skills/hostinger-mcp

Or simply re-clone. WSL also works. macOS/Linux need nothing.
