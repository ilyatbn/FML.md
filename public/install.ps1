# fml.md installer — https://fml.md
#
#   irm https://fml.md/install.ps1 | iex
#   $env:FML_AGENT='opencode'; irm https://fml.md/install.ps1 | iex
#   $env:FML_SCOPE='local'; irm https://fml.md/install.ps1 | iex
#
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
try { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 } catch {}

$base = $env:FML_BASE
if (-not $base) { $base = 'https://fml.md' }

$here = (Get-Location).Path

$agent = $env:FML_AGENT
if (-not $agent) { $agent = 'claude' }

# label, global root, local root, command source ($null = the skill is the command)
switch ($agent.Trim().ToLower()) {
  { $_ -in 'claude', 'claude-code' } {
    $label = 'Claude Code'
    $groot = Join-Path $HOME '.claude'
    $lroot = Join-Path $here '.claude'
    $cmdsrc = 'fml.md';          $invoke = '/fml'
  }
  'opencode' {
    $label = 'opencode'
    $groot = Join-Path $HOME '.config\opencode'
    $lroot = Join-Path $here '.opencode'
    $cmdsrc = 'fml.opencode.md'; $invoke = '/fml'
  }
  'codex' {
    $label = 'Codex CLI'
    $groot = Join-Path $HOME '.agents'
    $lroot = Join-Path $here '.agents'
    $cmdsrc = $null;             $invoke = '$fml'
  }
  'hermes' {
    $label = 'Hermes'
    $groot = Join-Path $HOME '.hermes'
    $lroot = Join-Path $here '.hermes'
    $cmdsrc = $null;             $invoke = '/fml'
  }
  default {
    throw "don't know that harness: $agent. Set `$env:FML_AGENT to claude, opencode, codex or hermes."
  }
}

$scope = $env:FML_SCOPE

if (-not $scope) {
  Write-Host ''
  Write-Host "  $label. Where do you want it?"
  Write-Host ''
  Write-Host "    g  global   $groot" -NoNewline
  Write-Host '  (every project)' -ForegroundColor DarkGray
  Write-Host "    r  repo     $lroot"
  Write-Host ''
  $ans = Read-Host '  [G/r]'
  switch -Regex ($ans.Trim()) {
    '^(g|global)?$'      { $scope = 'global' }
    '^(r|repo|l|local)$' { $scope = 'local' }
    default { throw "didn't catch that. Set `$env:FML_SCOPE='local' or 'global' and re-run." }
  }
}

if ($scope -eq 'global') {
  $root = $groot
} else {
  $root = $lroot
  if (-not (Test-Path (Join-Path $here '.git'))) {
    Write-Host "  No .git here - installing into $root anyway." -ForegroundColor DarkGray
  }
}

$skills = Join-Path $root 'skills\fml'
$cmds   = Join-Path $root 'commands'

$verb = 'installed'
if (Test-Path (Join-Path $skills 'SKILL.md')) { $verb = 'updated' }

$tmp = Join-Path ([IO.Path]::GetTempPath()) ('fml-' + [guid]::NewGuid())
New-Item -ItemType Directory -Force -Path $tmp | Out-Null
try {
  Invoke-WebRequest -UseBasicParsing "$base/fml/SKILL.md" -OutFile (Join-Path $tmp 'SKILL.md')

  if (-not (Select-String -Path (Join-Path $tmp 'SKILL.md') -Pattern '^name: fml$' -Quiet)) {
    throw "that download wasn't SKILL.md. Check $base and try again."
  }

  New-Item -ItemType Directory -Force -Path $skills | Out-Null
  Move-Item (Join-Path $tmp 'SKILL.md') (Join-Path $skills 'SKILL.md') -Force

  if ($cmdsrc) {
    Invoke-WebRequest -UseBasicParsing "$base/fml/$cmdsrc" -OutFile (Join-Path $tmp 'cmd.md')
    New-Item -ItemType Directory -Force -Path $cmds | Out-Null
    Move-Item (Join-Path $tmp 'cmd.md') (Join-Path $cmds 'fml.md') -Force
  }
} finally {
  Remove-Item -Recurse -Force $tmp -ErrorAction SilentlyContinue
}

Write-Host ''
Write-Host "  fml $verb for $label." -ForegroundColor Yellow
Write-Host "    skill   $skills\SKILL.md" -ForegroundColor DarkGray
if ($cmdsrc) {
  Write-Host "    command $cmds\fml.md" -ForegroundColor DarkGray
} else {
  Write-Host "    command the skill is the command" -ForegroundColor DarkGray
}
Write-Host ''
Write-Host "  Run $invoke <question>. Restart $label if it is already open."
Write-Host ''
