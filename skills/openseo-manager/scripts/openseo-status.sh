#!/usr/bin/env bash
# Read-only report of the OpenSEO setup in Claude Code. Changes nothing.
set -uo pipefail
# shellcheck source=common.sh
. "$(cd "$(dirname "$0")" && pwd)/common.sh"
need_claude

echo "Claude Code: $(claude --version 2>/dev/null | head -1)"

info="$(plugin_info)"
if [ -z "$info" ]; then
  echo "Plugin:      NOT INSTALLED ($PLUGIN_ID)"
  echo "Install:     claude plugin marketplace add $MARKETPLACE_REPO && claude plugin install $PLUGIN_ID --scope user"
else
  IFS=$'\t' read -r version path scope <<<"$info"
  echo "Plugin:      $PLUGIN_ID v$version (scope: $scope)"
  echo "Path:        $path"
  if [ -f "$path/.mcp.json" ]; then
    echo "MCP:         $(jq -r '.mcpServers | to_entries[] | "\(.key) -> \(.value.url // .value.command)"' "$path/.mcp.json" | paste -sd ' ' -)"
  fi
  if [ -d "$path/skills" ]; then
    echo "Skills:      $(find "$path/skills" -mindepth 2 -maxdepth 2 -name SKILL.md | wc -l | tr -d ' ') ($(ls "$path/skills" | paste -sd ' ' -))"
  fi
fi

# Hand-copied duplicates of plugin skills in personal or project skill folders.
dups=""
for dir in "$CLAUDE_DIR/skills" "$PWD/.claude/skills"; do
  [ -d "$dir" ] || continue
  while IFS= read -r f; do
    if grep -qiE 'openseo|open-seo' "$f" 2>/dev/null; then
      d="$(dirname "$f")"
      case "$d" in */openseo-manager) ;; *) dups="$dups $d" ;; esac
    fi
  done < <(find "$dir" -maxdepth 3 -name SKILL.md 2>/dev/null)
done
if [ -n "$dups" ]; then
  echo "Duplicates:  possible manual OpenSEO skill copies:$dups"
else
  echo "Duplicates:  none"
fi

if [ "$(uname)" = "Darwin" ]; then
  if launchctl list 2>/dev/null | grep -q 'com.openseo-manager.update'; then
    echo "Auto-update: ON (launchd)"
  else
    echo "Auto-update: OFF"
  fi
elif crontab -l 2>/dev/null | grep -q 'openseo-update.sh'; then
  echo "Auto-update: ON (cron)"
else
  echo "Auto-update: OFF"
fi
[ -f "$LOG_FILE" ] && echo "Last log:    $(tail -1 "$LOG_FILE")"
echo "Sign-in and tool access must be verified in a session with whoami + list_projects."
