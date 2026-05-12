Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$raw = [Console]::In.ReadToEnd()
if (-not $raw.Trim()) { exit 0 }
try { $data = $raw | ConvertFrom-Json } catch { exit 0 }

$toolName = if ($data.PSObject.Properties['tool_name']) { $data.tool_name } else { '' }
$toolInput = if ($data.PSObject.Properties['tool_input']) { $data.tool_input } else { $null }

# 1. Protect Terminal
if ($toolName -match 'execute/(runInTerminal|createAndRunTask)') {
    $cmd = if ($toolInput -and $toolInput.PSObject.Properties['command']) { [string]$toolInput.command } else { '' }
    $normalizedCommand = ($cmd -replace '\s+', ' ').Trim().ToLowerInvariant()
    if ($normalizedCommand -match '\b(rm\s+(-[a-z]*f[a-z]*|-rf|-fr|-r\s+-f|-f\s+-r)|(?:remove-item|rm|rmdir|rd|ri|del|erase)\b.*\b(recurse|force)\b|(?:del(ete)?|erase)\b.*\s/[sqf]+\b|(?:rmdir|rd)\b.*\s/[sqf]+\b|drop\s+(database|table|schema)\b|truncate\s+table\b|chmod\s+777\b|mkfs(?:\.\w+)?\b|format\s+[a-z]:\b|diskpart\b|dd\s+if=|wipefs\b|sdelete\b|shutdown\b)') {
        $msg = "CRITICAL SECURITY WARNING: You are attempting to run a highly destructive terminal command. This is strictly forbidden without explicit user consent. Halt and ask the user."
        $json = [PSCustomObject]@{ hookSpecificOutput = @{ hookEventName = 'PreToolUse'; additionalContext = $msg } } | ConvertTo-Json -Compress -Depth 5
        [Console]::Out.WriteLine($json)
        exit 1
    }
    exit 0
}

# 2. Protect Edits
if ($toolName -notmatch '(editFiles|replace_string_in_file)') { exit 0 }

$filePath = if ($toolInput -and $toolInput.PSObject.Properties['filePath']) { $toolInput.filePath } elseif ($toolInput -and $toolInput.PSObject.Properties['files']) { $toolInput.files[0] } else { '' }
if (-not $filePath) { exit 0 }

$transcriptPath = if ($data.PSObject.Properties['transcript_path']) { $data.transcript_path } else { '' }
if (-not $transcriptPath -or -not (Test-Path $transcriptPath)) { exit 0 }

$transcriptContent = Get-Content $transcriptPath -Raw
# Try full path first, then basename as fallback for relative paths
$escapedPath = [regex]::Escape($filePath)
$escapedBasename = [regex]::Escape((Split-Path $filePath -Leaf))
if ($transcriptContent -match $escapedPath -or $transcriptContent -match "(^|[\\/])$escapedBasename(`"|'|\s|$)") { exit 0 }

$basename = Split-Path $filePath -Leaf
$msg = "WARNING: You are editing $basename but there is no evidence you read it in this session. Read files before editing to avoid blind modifications."
$json = [PSCustomObject]@{ hookSpecificOutput = @{ hookEventName = 'PreToolUse'; additionalContext = $msg } } | ConvertTo-Json -Compress -Depth 5
[Console]::Out.WriteLine($json)
exit 1