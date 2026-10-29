#!/bin/bash
# Programme la mise à jour des skills Claude Code chaque mardi à 10h sur ce Mac (tâche launchd).
# Pour désactiver : launchctl bootout gui/$(id -u)/com.junity.claude-skills-update
#                   rm ~/Library/LaunchAgents/com.junity.claude-skills-update.plist
set -e
P="$HOME/Library/LaunchAgents/com.junity.claude-skills-update.plist"
mkdir -p "$HOME/Library/LaunchAgents"
cat > "$P" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key><string>com.junity.claude-skills-update</string>
  <key>ProgramArguments</key>
  <array>
    <string>/bin/bash</string><string>-c</string>
    <string>curl -fsSL https://raw.githubusercontent.com/JUNITY-SH/claude-skills-bundle/main/install.sh | /bin/bash</string>
  </array>
  <key>StartCalendarInterval</key>
  <dict><key>Weekday</key><integer>2</integer><key>Hour</key><integer>10</integer><key>Minute</key><integer>0</integer></dict>
  <key>StandardOutPath</key><string>$HOME/Library/Logs/claude-skills-update.log</string>
  <key>StandardErrorPath</key><string>$HOME/Library/Logs/claude-skills-update.log</string>
</dict>
</plist>
EOF
plutil -lint "$P" >/dev/null
launchctl bootout "gui/$(id -u)/com.junity.claude-skills-update" 2>/dev/null || true
launchctl bootstrap "gui/$(id -u)" "$P"
echo "Mise à jour hebdomadaire activée (mardi 10h). Journal : ~/Library/Logs/claude-skills-update.log"
