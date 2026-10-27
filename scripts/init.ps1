# Copy the SDD template without overwriting files. Usage: init.ps1 [-Target <dir>]
param([string]$Target = ".")

$ErrorActionPreference = "Stop"
# PowerShell 7 can otherwise throw on git's expected nonzero repository probe.
if (Test-Path Variable:PSNativeCommandUseErrorActionPreference) {
  $PSNativeCommandUseErrorActionPreference = $false
}
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$TemplateDir = [System.IO.Path]::GetFullPath((Join-Path $ScriptDir "..\assets\template"))
$Files = @("status.md", "spec.md", "plan.md", "history.md")

if (-not (Get-Command git -ErrorAction SilentlyContinue)) { throw "Git is not available." }
$existingAgent = Join-Path $Target ".agent"
$newStatus = Join-Path (Join-Path $Target ".agent") "status.md"
if ((Test-Path -LiteralPath $existingAgent -PathType Container) -and -not (Test-Path -LiteralPath $newStatus)) {
  throw "Existing .agent has no status.md; inspect its existing rules or repair the incomplete initialization. No automatic migration was performed."
}
foreach ($rel in (@("AGENTS.md") + @($Files | ForEach-Object { Join-Path ".agent" $_ }))) {
  $src = Join-Path $TemplateDir $rel
  if (-not (Test-Path -LiteralPath $src -PathType Leaf)) { throw "Template missing: $src" }
}

if (-not (Test-Path -LiteralPath $Target -PathType Container)) {
  New-Item -ItemType Directory -Path $Target -Force | Out-Null
}
$Target = (Resolve-Path -LiteralPath $Target).ProviderPath

# Native git writes diagnostics to stderr when the target is not a worktree.
$ErrorActionPreference = "Continue"
$inside = & git -C $Target rev-parse --is-inside-work-tree 2>&1
$probeExit = $LASTEXITCODE
$ErrorActionPreference = "Stop"
if ($probeExit -eq 0 -and "$inside" -eq "true") {
  Write-Output "Git repo already present."
} else {
  $ErrorActionPreference = "Continue"
  & git -C $Target init | Out-Null
  $initExit = $LASTEXITCODE
  $ErrorActionPreference = "Stop"
  if ($initExit -ne 0) { throw "Git initialization failed (exit $initExit)." }
  Write-Output "Git repo initialized."
}

$AgentDir = Join-Path $Target ".agent"
if (-not (Test-Path -LiteralPath $AgentDir -PathType Container)) {
  New-Item -ItemType Directory -Path $AgentDir -Force | Out-Null
}
$script:created = @()
$script:skipped = @()
function Copy-One([string]$src, [string]$dest) {
  if (Test-Path -LiteralPath $dest) { $script:skipped += $dest; return }
  # File.Copy's overwrite=false protects existing files even if created after the check.
  [System.IO.File]::Copy($src, $dest, $false)
  $script:created += $dest
}

Copy-One (Join-Path $TemplateDir "AGENTS.md") (Join-Path $Target "AGENTS.md")
foreach ($f in $Files) {
  Copy-One (Join-Path (Join-Path $TemplateDir ".agent") $f) (Join-Path $AgentDir $f)
}
Write-Output "Created:"
if ($script:created.Count -eq 0) { Write-Output "  (none)" }
$script:created | ForEach-Object { Write-Output "  $_" }
if ($script:skipped.Count -gt 0) {
  Write-Output "Skipped (already exist, NOT overwritten):"
  $script:skipped | ForEach-Object { Write-Output "  $_" }
}
Write-Output "Next: replace [PROJECT_NAME] in AGENTS.md; backfill technology after design; add the harness rule file and README; record D001 in plan.md and history.md, then make the first commit."
