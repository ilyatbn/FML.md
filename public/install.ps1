# fml.md installer — https://fml.md
#
#   irm https://fml.md/install.ps1 | iex
#   $env:FML_SCOPE='local'; irm https://fml.md/install.ps1 | iex
#
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
try { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 } catch {}

$base = $env:FML_BASE
if (-not $base) { $base = 'https://fml.md' }

$here = (Get-Location).Path
$scope = $env:FML_SCOPE

if (-not $scope) {
  Write-Host ''
  Write-Host '  Where do you want it?'
  Write-Host ''
  Write-Host "    g  global   $HOME\.claude" -NoNewline
  Write-Host '  (every project)' -ForegroundColor DarkGray
  Write-Host "    r  repo     $here\.claude"
  Write-Host ''
  $ans = Read-Host '  [G/r]'
  switch -Regex ($ans.Trim()) {
    '^(g|global)?$'      { $scope = 'global' }
    '^(r|repo|l|local)$' { $scope = 'local' }
    default { throw "didn't catch that. Set `$env:FML_SCOPE='local' or 'global' and re-run." }
  }
}

if ($scope -eq 'global') {
  $root = Join-Path $HOME '.claude'
} else {
  $root = Join-Path $here '.claude'
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
  Invoke-WebRequest -UseBasicParsing "$base/fml/fml.md"   -OutFile (Join-Path $tmp 'fml.md')

  if (-not (Select-String -Path (Join-Path $tmp 'SKILL.md') -Pattern '^name: fml$' -Quiet)) {
    throw "that download wasn't SKILL.md. Check $base and try again."
  }

  New-Item -ItemType Directory -Force -Path $skills, $cmds | Out-Null
  Move-Item (Join-Path $tmp 'SKILL.md') (Join-Path $skills 'SKILL.md') -Force
  Move-Item (Join-Path $tmp 'fml.md')   (Join-Path $cmds 'fml.md')     -Force
} finally {
  Remove-Item -Recurse -Force $tmp -ErrorAction SilentlyContinue
}

Write-Host ''
Write-Host "  fml $verb." -ForegroundColor Yellow
Write-Host "    skill   $skills\SKILL.md" -ForegroundColor DarkGray
Write-Host "    command $cmds\fml.md" -ForegroundColor DarkGray
Write-Host ''
Write-Host '  Run /fml <question>. Restart Claude Code if it is already open.'
Write-Host ''
