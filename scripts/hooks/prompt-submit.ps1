# UserPromptSubmit hook: Injects strict context to prevent small-model hallucination,
# enforces official subagents, detects Autopilot keywords (ULW, YOLO),
# and blocks anti-patterns (skip tests, skip review).

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$raw = [Console]::In.ReadToEnd()
if (-not $raw.Trim()) { exit 0 }
try { $data = $raw | ConvertFrom-Json } catch { exit 0 } # non-JSON input (e.g. ping) is not an error

$prompt = if ($data.PSObject.Properties['prompt']) { [string]$data.prompt } else { '' }
if (-not $prompt) { exit 0 }

$defaultRoster = @('sentry', 'metis', 'oracle', 'killua', 'ekko', 'aurora', 'forge', 'nova', 'prometheus')
$roster = @()
if ($env:AGENT_ROSTER) {
    $candidateRoster = @($env:AGENT_ROSTER -split ',' | ForEach-Object { $_.Trim() })
    if ($candidateRoster.Count -gt 0 -and (@($candidateRoster | Where-Object { -not $_ -or $_ -notmatch '^[a-zA-Z0-9_-]+$' }).Count -eq 0)) {
        $roster = $candidateRoster
    }
}
if ($roster.Count -eq 0) { $roster = $defaultRoster }
$rosterText = $roster -join ', '

# 1. Base Reinforcement (Always injected to ground smaller models)
$message = "SYSTEM REINFORCEMENT: Follow your strict workflow. DO NOT hallucinate or invent custom subagents. ONLY delegate to the official roster: $rosterText. Actively use your available tools to research; do not guess. Do not skip steps or lie to please."

# 2. Check for Autopilot keywords (whole words, case-insensitive)
if ($prompt -match '(?i)\b(ULW|YOLO)\b') {
    $message += "`n`nMODE OVERRIDE: Autopilot mode detected. Proceed autonomously without user stops. Auto-commit after sentry approval. Present final summary when all work is done."
}

# 3. Check for anti-patterns (case-insensitive)
$promptLower = $prompt.ToLower() -replace '[\u2018\u2019]', "'"
$antiPatterns = @("without testing","skip tests","skip review","don't test","no tests")
$qualityWarningAdded = $false
foreach ($p in $antiPatterns) {
    if ($promptLower.Contains($p)) {
        $message += "`n`nWARNING: The user's prompt suggests skipping quality gates. All tests and reviews are MANDATORY per Core Philosophy. Proceed with full quality enforcement."
        $qualityWarningAdded = $true
        break
    }
}

# Output JSON payload
[PSCustomObject]@{
    hookSpecificOutput = [PSCustomObject]@{
        hookEventName   = 'UserPromptSubmit'
        additionalContext = $message
    }
} | ConvertTo-Json -Compress -Depth 5
exit 0