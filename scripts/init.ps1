# SDD scaffold init: copy skill template into a target directory.
# Idempotent, never overwrites existing files. Git init only (first commit is
# made by the agent after customization). Usage: init.ps1 [-Target <dir>]
param([string]$Target = ".")

$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$TemplateDir = Join-Path $ScriptDir "..\assets\template"

if (-not (Test-Path (Join-Path $TemplateDir "AGENTS.md"))) {
  Write-Error "Template not found at $TemplateDir (keep scripts/ next to assets/)"
}

$AgentDir = Join-Path $Target ".agent"
New-Item -ItemType Directory -Force -Path $AgentDir | Out-Null

$script:created = @()
$script:skipped = @()
function Copy-One([string]$src, [string]$dest) {
  if (Test-Path $dest) { $script:skipped += $dest }
  else { Copy-Item $src $dest; $script:created += $dest }
}

Copy-One (Join-Path $TemplateDir "AGENTS.md") (Join-Path $Target "AGENTS.md")
Get-ChildItem (Join-Path $TemplateDir ".agent") -Filter *.md | ForEach-Object {
  Copy-One $_.FullName (Join-Path $AgentDir $_.Name)
}

Write-Output "Created:"
$script:created | ForEach-Object { Write-Output "  $_" }
if ($script:skipped.Count -gt 0) {
  Write-Output "Skipped (already exist, NOT overwritten):"
  $script:skipped | ForEach-Object { Write-Output "  $_" }
}

# git writes to stderr when outside a repo; relax EAP so the probe can't throw
$ErrorActionPreference = "Continue"
$null = & git -C $Target rev-parse --is-inside-work-tree 2>&1
$insideRepo = ($LASTEXITCODE -eq 0)
$ErrorActionPreference = "Stop"

if ($insideRepo) {
  Write-Output "Git repo already present."
} else {
  git -C $Target init | Out-Null
  Write-Output "Git repo initialized."
}
Write-Output "Next: replace [PROJECT_NAME] in AGENTS.md (tech-stack placeholders are backfilled after the design phase), add harness rule file, write README.md, decisions.md D001, then first commit."
