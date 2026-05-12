param([Parameter(Mandatory)][string]$Hook)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'

if ($Hook -notmatch '^[a-zA-Z0-9_-]+$') {
    [Console]::Error.WriteLine("atlas: invalid hook name '$Hook'")
    exit 1
}

$script = Join-Path (Split-Path -Parent $PSCommandPath) "$Hook.ps1"
if (-not (Test-Path $script)) {
    [Console]::Error.WriteLine("atlas: $Hook hook not found")
    exit 1
}

$childPowerShell = Get-Command pwsh -CommandType Application -ErrorAction SilentlyContinue
if (-not $childPowerShell) {
    $childPowerShell = Get-Command powershell -CommandType Application -ErrorAction SilentlyContinue
}

if (-not $childPowerShell) {
    [Console]::Error.WriteLine('atlas: PowerShell executable not found')
    exit 1
}

$stdin = [Console]::In.ReadToEnd()
if ($stdin) {
    $stdin | & $childPowerShell.Path -NoLogo -NoProfile -NonInteractive -File $script @args
} else {
    & $childPowerShell.Path -NoLogo -NoProfile -NonInteractive -File $script @args
}

$exitCode = if ($null -ne $LASTEXITCODE) { [int]$LASTEXITCODE } else { 0 }
exit $exitCode