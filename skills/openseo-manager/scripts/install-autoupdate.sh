#!/usr/bin/env bash
# Schedule openseo-update.sh daily (and at login on macOS).
# macOS: launchd agent. Linux: user crontab. Re-running replaces the old entry.
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=common.sh
. "$here/common.sh"
# Copy the updater to a stable path: plugin cache paths change on every version.
mkdir -p "$STATE_DIR/bin"
cp "$here/common.sh" "$here/openseo-update.sh" "$STATE_DIR/bin/"
script="$STATE_DIR/bin/openseo-update.sh"
chmod +x "$script"
hour="${OPENSEO_UPDATE_HOUR:-9}"

if [ "$(uname)" = "Darwin" ]; then
  label="com.openseo-manager.update"
  plist="$HOME/Library/LaunchAgents/$label.plist"
  mkdir -p "$(dirname "$plist")"
  cat >"$plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key><string>$label</string>
  <key>ProgramArguments</key>
  <array><string>/bin/bash</string><string>$script</string></array>
  <key>StartCalendarInterval</key>
  <dict><key>Hour</key><integer>$hour</integer><key>Minute</key><integer>0</integer></dict>
  <key>RunAtLoad</key><true/>
  <key>StandardOutPath</key><string>$LOG_FILE</string>
  <key>StandardErrorPath</key><string>$LOG_FILE</string>
</dict>
</plist>
EOF
  launchctl bootout "gui/$(id -u)/$label" 2>/dev/null || true
  launchctl bootstrap "gui/$(id -u)" "$plist"
  echo "Auto-update ON: launchd '$label' daily at $hour:00 and at login."
else
  line="0 $hour * * * /bin/bash '$script' >> '$LOG_FILE' 2>&1"
  { crontab -l 2>/dev/null | grep -v 'openseo-update.sh' || true; echo "$line"; } | crontab -
  echo "Auto-update ON: cron daily at $hour:00."
fi
echo "Log: $LOG_FILE"
