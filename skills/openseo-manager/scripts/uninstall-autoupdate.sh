#!/usr/bin/env bash
# Remove the scheduled OpenSEO auto-update. Leaves the plugin and logs in place.
set -euo pipefail
if [ "$(uname)" = "Darwin" ]; then
  label="com.openseo-manager.update"
  launchctl bootout "gui/$(id -u)/$label" 2>/dev/null || true
  rm -f "$HOME/Library/LaunchAgents/$label.plist"
else
  { crontab -l 2>/dev/null | grep -v 'openseo-update.sh' || true; } | crontab -
fi
echo "Auto-update OFF."
