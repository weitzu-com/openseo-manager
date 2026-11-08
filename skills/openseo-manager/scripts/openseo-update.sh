#!/usr/bin/env bash
# Update the OpenSEO marketplace and plugin in their existing scope.
# Idempotent; safe to run from launchd/cron. Never touches other plugins.
set -uo pipefail
# shellcheck source=common.sh
. "$(cd "$(dirname "$0")" && pwd)/common.sh"
mkdir -p "$STATE_DIR"
need_claude

before="$(plugin_info)"
if [ -z "$before" ]; then
  log "OpenSEO plugin is not installed; nothing to update."
  log "Install: claude plugin marketplace add $MARKETPLACE_REPO && claude plugin install $PLUGIN_ID --scope user"
  exit 0
fi
IFS=$'\t' read -r old_ver old_path scope <<<"$before"

log "Refreshing marketplace '$MARKETPLACE'"
if ! claude plugin marketplace update "$MARKETPLACE" >/dev/null 2>&1; then
  log "ERROR: marketplace update failed"
  exit 1
fi

log "Updating $PLUGIN_ID (scope: $scope, current v$old_ver)"
out="$(claude plugin update "$PLUGIN_ID" --scope "$scope" 2>&1)"
rc=$?
printf '%s\n' "$out" | sed 's/^/  /'
[ $rc -eq 0 ] || { log "ERROR: plugin update failed ($rc)"; exit $rc; }

IFS=$'\t' read -r new_ver new_path _ <<<"$(plugin_info)"
if [ "$new_ver" = "$old_ver" ]; then
  log "Already current: v$new_ver"
  exit 0
fi

log "Updated v$old_ver -> v$new_ver"
if [ -d "$old_path/skills" ] && [ -d "$new_path/skills" ]; then
  changes="$(diff -rq "$old_path/skills" "$new_path/skills" 2>/dev/null)"
  if [ -n "$changes" ]; then
    log "Skill file changes:"
    printf '%s\n' "$changes" | sed "s#$old_path/##g; s#$new_path/##g; s/^/  /"
  else
    log "Skill files unchanged (manifest/tooling only)"
  fi
fi
log "Start a new Claude session to load v$new_ver."
