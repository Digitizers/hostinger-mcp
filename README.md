# Hostinger MCP — Claude Code & OpenClaw Skill

[![CI](https://github.com/Digitizers/hostinger-mcp/actions/workflows/ci.yml/badge.svg)](https://github.com/Digitizers/hostinger-mcp/actions/workflows/ci.yml)
![Claude Code Skill](https://img.shields.io/badge/Claude_Code-Skill-d97757)
![OpenClaw Skill](https://img.shields.io/badge/OpenClaw-Skill-purple)
![Hostinger](https://img.shields.io/badge/Hostinger-MCP-673de6)
![License: MIT](https://img.shields.io/badge/License-MIT-green)
![Version](https://img.shields.io/badge/version-1.0.0-blue)

A production-grade **Claude Code & OpenClaw skill** for managing [Hostinger](https://www.hostinger.com/) infrastructure — VPS, websites, domains, DNS, email (Reach), and billing — through the official **Hostinger MCP server**, across one or many accounts, with a safety rule on every write.

This is not just a tool reference. It is an operational playbook for running Hostinger responsibly: category-scoped tool loading (so you never drown in 127 tools at once), VPS provisioning and lifecycle, domain/DNS changes, and money-spending guardrails — with write-confirmation on anything that changes state or costs money.

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
    ├── tools-catalog.md           # all 127 tools, 7 categories, R / W / W!
    └── workflows-vps.md           # flagship VPS playbook
```

## Activation

The skill activates when Hostinger is discussed and a `hostinger-*` MCP server is connected (tools appear as `mcp__hostinger*__*`). For setup — see [`installation.md`](.claude/skills/hostinger-mcp/references/installation.md) and [`.mcp.json.example`](.mcp.json.example). Install with `npm i -g hostinger-api-mcp`; authenticate with a `HOSTINGER_API_TOKEN` from hPanel.

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
