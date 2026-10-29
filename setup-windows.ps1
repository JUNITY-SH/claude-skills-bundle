# Installe sur un PC Windows : le CLAUDE.md global, les skills du bundle,
# et une tâche planifiée qui met les skills à jour chaque mardi à 10h.
# Usage (PowerShell) :
#   irm https://raw.githubusercontent.com/JUNITY-SH/claude-skills-bundle/main/setup-windows.ps1 | iex
# Pour désactiver la tâche : Unregister-ScheduledTask -TaskName "Claude skills update" -Confirm:$false

$ErrorActionPreference = "Stop"
$Base = "https://raw.githubusercontent.com/JUNITY-SH/claude-skills-bundle/main"
$ClaudeDir = Join-Path $env:USERPROFILE ".claude"

# 1. Git Bash (requis par Claude Code sur Windows, et par install.sh)
$Bash = @($env:ProgramFiles, ${env:ProgramFiles(x86)}, "$env:LOCALAPPDATA\Programs") |
  Where-Object { $_ } | ForEach-Object { "$_\Git\bin\bash.exe" } |
  Where-Object { Test-Path $_ } | Select-Object -First 1
if (-not $Bash) {
  Write-Host "Git for Windows est introuvable. Installe-le (https://git-scm.com/download/win) puis relance ce script." -ForegroundColor Red
  return
}

# 2. CLAUDE.md global (l'ancien est sauvegardé s'il existe et diffère)
New-Item -ItemType Directory -Force -Path $ClaudeDir | Out-Null
$Target = Join-Path $ClaudeDir "CLAUDE.md"
$New = Join-Path $env:TEMP "CLAUDE.md.new"
Invoke-WebRequest -UseBasicParsing "$Base/rules/CLAUDE.md" -OutFile $New
if ((Test-Path $Target) -and ((Get-FileHash $Target).Hash -ne (Get-FileHash $New).Hash)) {
  $Backup = "$Target.bak-$(Get-Date -Format yyyyMMdd-HHmmss)"
  Copy-Item $Target $Backup
  Write-Host "Ancien CLAUDE.md sauvegardé dans $Backup"
}
Move-Item -Force $New $Target
Write-Host "CLAUDE.md global installé : $Target"

# 3. Skills (même script que sur Mac et dans le cloud, exécuté par Git Bash)
$Cmd = "curl -fsSL $Base/install.sh | bash >> ~/.claude/skills-update.log 2>&1"
& $Bash -lc $Cmd
Get-Content (Join-Path $ClaudeDir "skills-update.log") -Tail 1

# 4. Tâche planifiée hebdomadaire (session utilisateur, sans mot de passe)
$Action = New-ScheduledTaskAction -Execute $Bash -Argument "-lc `"$Cmd`""
$Trigger = New-ScheduledTaskTrigger -Weekly -DaysOfWeek Tuesday -At 10am
$Settings = New-ScheduledTaskSettingsSet -StartWhenAvailable -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries
$Principal = New-ScheduledTaskPrincipal -UserId "$env:USERDOMAIN\$env:USERNAME" -LogonType Interactive
Register-ScheduledTask -TaskName "Claude skills update" -Action $Action -Trigger $Trigger `
  -Settings $Settings -Principal $Principal -Force | Out-Null
Write-Host "Mise à jour hebdomadaire activée (mardi 10h). Journal : $ClaudeDir\skills-update.log" -ForegroundColor Green
