Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$raw = [Console]::In.ReadToEnd()
if (-not $raw.Trim()) { exit 0 }
try { $data = $raw | ConvertFrom-Json } catch { exit 0 }

$transcriptPath = if ($data.PSObject.Properties['transcript_path']) { $data.transcript_path } else { '' }
$snapshot = "Context compaction imminent. Save important session state to /memories/session/ now."

if ($transcriptPath -and (Test-Path $transcriptPath)) {
    try {
        $jq = Get-Command jq -CommandType Application -ErrorAction SilentlyContinue
        if (-not $jq) { throw "jq not available" }

        $msgCount = & $jq.Path 'length' $transcriptPath 2>$null
        if ($LASTEXITCODE -ne 0) { throw "jq exited with code $LASTEXITCODE" }
        $msgCountText = ([string]$msgCount).Trim()

        $snapshot = "Context compaction imminent. Session state snapshot:`n- Messages in transcript: $msgCountText`nSave any critical state to /memories/session/ before it is lost."
    } catch {
        $message = "pre-compact: failed to read transcript '$transcriptPath': $($_.Exception.Message)"
        [Console]::Error.WriteLine($message)
        Write-Verbose $message
    }
}

[PSCustomObject]@{ systemMessage = $snapshot } | ConvertTo-Json -Compress
exit 0