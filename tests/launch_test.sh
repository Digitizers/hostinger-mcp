#!/bin/sh
# Tests for bin/launch.sh with stub binaries; nothing is fetched or installed.
set -u
here=$(cd "$(dirname "$0")/.." && pwd)
t=$(mktemp -d); trap 'rm -rf "$t"' EXIT
fail=0
mkbin() {  # $1 = dir for a fake package install, $2 = version
  mkdir -p "$1/node_modules/hostinger-api-mcp/src" "$1/node_modules/.bin"
  printf '{\n  "name": "hostinger-api-mcp",\n  "version": "%s"\n}\n' "$2" > "$1/node_modules/hostinger-api-mcp/package.json"
  printf '#!/bin/sh\necho "ran $0"\n' > "$1/node_modules/hostinger-api-mcp/src/all.js"
  chmod +x "$1/node_modules/hostinger-api-mcp/src/all.js"
  ln -sf ../hostinger-api-mcp/src/all.js "$1/node_modules/.bin/hostinger-api-mcp"
}
mkdir -p "$t/stub"; printf '#!/bin/sh\necho "npx $*"\n' > "$t/stub/npx"; chmod +x "$t/stub/npx"
check() {  # $1 = name, $2 = expected substring, rest = env assignments
  name=$1; want=$2; shift 2
  out=$(env -i HOME="$t/home" "$@" sh "$here/bin/launch.sh" hostinger-api-mcp 2>&1)
  case "$out" in *"$want"*) echo "ok   $name" ;; *) echo "FAIL $name: got '$out'"; fail=1 ;; esac
}
mkbin "$t/pinned" 1.8.2
mkbin "$t/old" 0.2.4
mkbin "$t/globalpinned" 1.8.2
check "verified prefix is used" "ran" PATH="$t/stub:/usr/bin:/bin" HOSTINGER_MCP_PREFIX="$t/pinned"
check "wrong-version prefix falls back to npx" "npx -y -p hostinger-api-mcp@1.8.2 -- hostinger-api-mcp" PATH="$t/stub:/usr/bin:/bin" HOSTINGER_MCP_PREFIX="$t/old"
check "wrong-version global falls back to npx" "npx -y -p" PATH="$t/old/node_modules/.bin:$t/stub:/usr/bin:/bin" HOSTINGER_MCP_PREFIX="$t/none"
check "pinned global is used" "ran" PATH="$t/globalpinned/node_modules/.bin:$t/stub:/usr/bin:/bin" HOSTINGER_MCP_PREFIX="$t/none"
out=$(env -i HOME="$t/home" PATH="$t/stub:/usr/bin:/bin" sh "$here/bin/launch.sh" "evil; rm -rf /" 2>&1); [ $? = 2 ] && echo "ok   unknown binary refused" || { echo "FAIL unknown binary: $out"; fail=1; }
exit $fail
