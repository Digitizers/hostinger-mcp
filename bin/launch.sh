#!/bin/sh
# Start the pinned Hostinger MCP server without a resident `npm exec` process when a
# verified install of the pinned version is present; otherwise use the pinned npx route.
#
# Lookup order, first match wins:
#   1. $HOSTINGER_MCP_PREFIX (default ~/.local/share/hostinger-mcp/hostinger-api-mcp-$PIN),
#      the versioned prefix that references/installation.md installs into
#   2. the binary on PATH, only if its package.json says exactly $PIN
#   3. npx -y -p hostinger-api-mcp@$PIN (pinned, unverified; see installation.md)
#
# Each `npx` session keeps an `npm exec` process alive beside the server; with many
# Claude Code sessions those wrappers add up. Paths 1 and 2 avoid them.
PIN=1.8.2
BIN=${1:-hostinger-api-mcp}
case "$BIN" in
  hostinger-api-mcp|hostinger-*-mcp) ;;
  *) echo "launch.sh: unknown Hostinger MCP binary: $BIN" >&2; exit 2 ;;
esac

PREFIX=${HOSTINGER_MCP_PREFIX:-$HOME/.local/share/hostinger-mcp/hostinger-api-mcp-$PIN}
pinned() {  # $1 = package dir; true only when its package.json declares exactly $PIN
  v=$(sed -n 's/^[[:space:]]*"version":[[:space:]]*"\([^"]*\)".*/\1/p' "$1/package.json" 2>/dev/null | head -n 1)
  [ "$v" = "$PIN" ]
}

if [ -x "$PREFIX/node_modules/.bin/$BIN" ] && pinned "$PREFIX/node_modules/hostinger-api-mcp"; then
  exec "$PREFIX/node_modules/.bin/$BIN"
fi

P=$(command -v "$BIN" 2>/dev/null)
if [ -n "$P" ]; then
  R=$(readlink -f "$P" 2>/dev/null || echo "$P")
  case "$R" in
    */node_modules/hostinger-api-mcp/*)
      if pinned "${R%%/node_modules/hostinger-api-mcp/*}/node_modules/hostinger-api-mcp"; then
        exec "$P"
      fi ;;
  esac
fi

exec npx -y -p "hostinger-api-mcp@$PIN" -- "$BIN"
