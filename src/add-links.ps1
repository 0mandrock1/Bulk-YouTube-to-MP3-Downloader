[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

Write-Host ""
Write-Host "=== Adding links to links.json ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "Choose an option:"
Write-Host "1 - Create new file (clear old)"
Write-Host "2 - Add links to existing file"
Write-Host ""

$choice = Read-Host "Your choice (1 or 2)"

if ($choice -eq "1") {
    @() | ConvertTo-Json | Out-File -Encoding UTF8 links.json
    Write-Host "New links.json file created" -ForegroundColor Green
} elseif ($choice -eq "2") {
    if (-not (Test-Path links.json)) {
        Write-Host "links.json file not found. Creating new..." -ForegroundColor Yellow
        @() | ConvertTo-Json | Out-File -Encoding UTF8 links.json
    } else {
        Write-Host "Links will be added to existing file" -ForegroundColor Green
    }
} else {
    Write-Host "Error: invalid choice" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host ""
Write-Host "=== Adding links to links.json ===" -ForegroundColor Cyan
Write-Host "(to finish enter N, or exit to quit)" -ForegroundColor Gray
Write-Host ""

$links = @()
if (Test-Path links.json) {
    $content = Get-Content links.json -Raw
    if ($content.Trim() -and $content.Trim() -ne "[]") {
        try {
            $links = @($content | ConvertFrom-Json)
            if ($links -is [string]) {
                $links = @($links)
            }
        } catch {
            $links = @()
        }
    }
}

$firstLink = ($links.Count -eq 0)
$shouldExit = $false

while (-not $shouldExit) {
    $link = Read-Host "Enter link"
    
    $link = $link.Trim()
    
    if ($link -eq "" -or $link -eq "0") {
        continue
    }
    
    if ($link -imatch "^(N|exit|quit|q|e)$") {
        if ($firstLink) {
            Write-Host "Error: no links were added" -ForegroundColor Red
            continue
        }
        Write-Host ""
        Write-Host "Done. Links saved to links.json" -ForegroundColor Green
        $shouldExit = $true
        break
    }
    
    # Validate YouTube URL
    if ($link -notmatch "youtube\.com|youtu\.be") {
        Write-Host "Error: link must be a YouTube URL" -ForegroundColor Red
        continue
    }
    
    # Clean up unnecessary parameters
    # Remove pp parameter (telemetry)
    $link = $link -replace "&pp=[^&]*", ""
    $link = $link -replace "^pp=[^&]*&", ""
    
    # Remove start_radio parameter but keep the link
    # (user can still download the radio if they want the original)
    # Just notify them
    if ($link -match "start_radio=1") {
        Write-Host "Note: removing start_radio parameter from URL" -ForegroundColor Gray
        $link = $link -replace "&start_radio=1", ""
        $link = $link -replace "start_radio=1&", ""
    }
    
    # Check for duplicate
    if ($link -in $links) {
        Write-Host "Error: this link already exists" -ForegroundColor Yellow
        continue
    }
    
    # Add link
    $links += $link
    $firstLink = $false
    Write-Host "Link added!" -ForegroundColor Green
}

# Save to JSON
$links | ConvertTo-Json | Out-File -Encoding UTF8 links.json

Write-Host ""
Write-Host "All done!" -ForegroundColor Green
