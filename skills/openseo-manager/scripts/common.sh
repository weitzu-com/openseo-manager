# shellcheck shell=bash
# Shared helpers for openseo-manager scripts. Sourced, not executed.

PLUGIN_ID="openseo@openseo"
MARKETPLACE="openseo"
MARKETPLACE_REPO="every-app/open-seo"
CLAUDE_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
PLUGINS_JSON="$CLAUDE_DIR/plugins/installed_plugins.json"
STATE_DIR="$CLAUDE_DIR/openseo-manager"
LOG_FILE="$STATE_DIR/update.log"

# launchd and cron run with a minimal PATH; add the usual install locations.
export PATH="$HOME/.local/bin:$HOME/.claude/local:/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:$PATH"

log() { printf '%s %s\n' "$(date '+%Y-%m-%dT%H:%M:%S%z')" "$*"; }

need_claude() {
  if ! command -v claude >/dev/null 2>&1; then
    log "ERROR: claude CLI not found on PATH"
    exit 127
  fi
}

# Prints "<version>\t<installPath>\t<scope>" for the OpenSEO plugin, or nothing.
plugin_info() {
  [ -f "$PLUGINS_JSON" ] || return 0
  jq -r --arg id "$PLUGIN_ID" \
    '.plugins[$id][0]? // empty | [.version, .installPath, .scope] | @tsv' \
    "$PLUGINS_JSON" 2>/dev/null
}
