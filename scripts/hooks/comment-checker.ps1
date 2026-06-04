Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$raw = [Console]::In.ReadToEnd()
if (-not $raw.Trim()) { exit 0 }
try { $data = $raw | ConvertFrom-Json } catch { exit 0 }

$toolName = if ($data.PSObject.Properties['tool_name']) { $data.tool_name } else { '' }
$toolInput = if ($data.PSObject.Properties['tool_input']) { $data.tool_input } else { $null }
if ($toolName -notmatch '(editFiles|create_file|replace_string_in_file|multi_replace_string_in_file)') { exit 0 }

$filePath = if ($toolInput -and $toolInput.PSObject.Properties['filePath']) { $toolInput.filePath } elseif ($toolInput -and $toolInput.PSObject.Properties['files']) { $toolInput.files[0] } else { '' }
if (-not $filePath -or -not (Test-Path $filePath)) { exit 0 }

$ext = (Split-Path $filePath -Extension).TrimStart('.').ToLower()
$lines = @(Get-Content $filePath)
if ($lines.Count -lt 10) { exit 0 }

$totalLines = 0
$commentLines = 0
$inJsDoc = $false
$inBlockComment = $false

foreach ($line in $lines) {
    $trimmed = $line.Trim()
    if (-not $trimmed) { continue }
    $totalLines++

    if ($inJsDoc) { if ($trimmed -match '\*/$') { $inJsDoc = $false }; continue }
    if ($inBlockComment) { 
        $commentLines++
        if ($trimmed -match '\*/$' -or ($ext -eq 'ps1' -and $trimmed -match '#>')) { $inBlockComment = $false }
        continue 
    }

    if ($trimmed.StartsWith("/**")) { if ($trimmed -notmatch '\*/$') { $inJsDoc = $true }; continue }
    if ($trimmed.StartsWith("/*")) { $commentLines++; if ($trimmed -notmatch '\*/$') { $inBlockComment = $true }; continue }

    if ($ext -match '^(js|ts|tsx|jsx|go|java|c|cpp|rs|swift|kt|cs)$') {
        if ($trimmed.StartsWith("//") -and $trimmed -notmatch '^//\s*(eslint-disable|@ts-|prettier-ignore|noinspection)') { $commentLines++ }
    } elseif ($ext -eq 'py') {
        if ($trimmed.StartsWith("#") -and $trimmed -notmatch '^#\s*(type:|noqa|pylint:|fmt:|isort:)') { $commentLines++ }
    } elseif ($ext -match '^(sh|bash|zsh|yml|yaml|toml|rb)$') {
        if ($trimmed.StartsWith("#") -and $trimmed -notmatch '^#\s*(shellcheck|rubocop)') { $commentLines++ }
    } elseif ($ext -match '^(html|xml|svg|vue)$') {
        if ($trimmed.StartsWith("<!--")) { $commentLines++ }
    } elseif ($ext -eq 'ps1') {
        if ($trimmed.StartsWith("<#")) { $commentLines++; if ($trimmed -notmatch '#>') { $inBlockComment = $true } }
        elseif ($trimmed.StartsWith("#") -and $trimmed -notmatch '^#\s*(Requires|region|endregion)') { $commentLines++ }
    }
}

if ($totalLines -gt 0) {
    $ratio = [math]::Round(($commentLines / $totalLines) * 100)
    if ($ratio -gt 30) {
        $basename = Split-Path $filePath -Leaf
        $msg = "WARNING: $basename has $ratio% comment density. Comments exceeding 30% often indicate AI slop. Remove comments that add no value."
        [PSCustomObject]@{ hookSpecificOutput = @{ hookEventName = 'PostToolUse'; additionalContext = $msg } } | ConvertTo-Json -Compress
    }
}
exit 0