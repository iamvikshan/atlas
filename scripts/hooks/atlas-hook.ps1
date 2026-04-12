param([Parameter(Mandatory)][string]$Hook)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if ($Hook -notmatch '^[a-zA-Z0-9_-]+$') {
    [Console]::Error.WriteLine("atlas: invalid hook name '$Hook'")
    exit 1
}

$script = Join-Path (Split-Path -Parent $PSCommandPath) "$Hook.ps1"
if (-not (Test-Path $script)) {
    [Console]::Error.WriteLine("atlas: $Hook hook not found")
    exit 1
}

& powershell.exe -NonInteractive -NoProfile -File $script @args
exit $LASTEXITCODE
