[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

function Get-CleanFilename {
    param([string]$basename)

    # Strip YouTube ID at the end: [xxxxxxxxxxx]
    $ytIdMatch = [regex]::Match($basename, '\s*\[([A-Za-z0-9_-]{11})\]$')
    $title     = if ($ytIdMatch.Success) { $basename.Substring(0, $ytIdMatch.Index) } else { $basename }

    # Remove bracket groups and their contents
    $title = $title -replace '\([^)]*\)', ''
    $title = $title -replace '\[[^\]]*\]', ''
    $title = $title -replace '\{[^}]*\}', ''
    # CJK/fullwidth brackets
    $title = $title -replace '[【】『』「」〔〕《》〈〉]', ''
    # Misc noise characters
    $title = $title -replace '[|#@\$%\^=\+`~]', ''
    # Collapse and trim whitespace/dashes
    $title = $title -replace '\s{2,}', ' '
    $title = $title -replace '[-\s]+$', ''
    $title = $title -replace '^[-\s]+', ''
    $title = $title.Trim()

    return $title
}

Write-Host "Bulk YouTube to MP3 Downloader" -ForegroundColor Cyan
Write-Host "by mandrock0 (based on work EDM115)" -ForegroundColor Gray
Write-Host ""
Write-Host "Checking requirements..." -ForegroundColor Yellow

# Check requirements
$requirements = @("yt-dlp", "ffmpeg", "ffprobe")
$missingTools = @()

foreach ($tool in $requirements) {
    $exists = $null -ne (Get-Command $tool -ErrorAction SilentlyContinue)
    if ($exists) {
        Write-Host "Found $tool" -ForegroundColor Green
    } else {
        Write-Host "ERROR: $tool not found in PATH" -ForegroundColor Red
        $missingTools += $tool
    }
}

if ($missingTools.Count -gt 0) {
    Write-Host ""
    Write-Host "Missing tools: $($missingTools -join ', ')" -ForegroundColor Red
    Write-Host "Tip: add the folder containing these tools to your PATH" -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit 1
}

# Check links.json
if (-not (Test-Path "links.json")) {
    Write-Host "ERROR: links.json not found in $(Get-Location)" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

# Create downloads folder
if (-not (Test-Path "downloads")) {
    New-Item -ItemType Directory -Name "downloads" -Force > $null
}

Write-Host "All requirements met." -ForegroundColor Green
Write-Host ""

# Parse extra arguments
$extraArgs = @($args)
if ($extraArgs.Count -gt 0) {
    Write-Host "Extra yt-dlp args detected (they override defaults if duplicated):" -ForegroundColor Yellow
    Write-Host "   $($extraArgs -join ' ')" -ForegroundColor Gray
    Write-Host ""
}

# Parse links.json
Write-Host "Parsing links.json..." -ForegroundColor Yellow
try {
    $content = Get-Content "links.json" -Raw
    $links = $content | ConvertFrom-Json
    
    # Handle both array and single string
    if ($links -is [string]) {
        $links = @($links)
    } elseif ($links -isnot [array]) {
        $links = @($links)
    }
    
    # Filter empty strings
    $links = @($links | Where-Object { $_ -and $_.Trim() })
} catch {
    Write-Host "ERROR: Failed to parse links.json - $($_.Exception.Message)" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

if ($links.Count -eq 0) {
    Write-Host "ERROR: No URLs found in links.json" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host "Found $($links.Count) link(s)" -ForegroundColor Green
Write-Host ""

# Download settings
$defaultArgs = @(
    "-f", "bestaudio/best",
    "--extract-audio",
    "--audio-format", "mp3",
    "--audio-quality", "0",
    "--embed-subs",
    "--embed-thumbnail",
    "--embed-metadata",
    "--embed-chapters",
    "--windows-filenames",
    "--progress",
    "--console-title",
    "-o", "downloads\%(title)s [%(id)s].%(ext)s"
)

# Download each URL
$count = 0
foreach ($url in $links) {
    $count++
    Write-Host "Processing link $count/$($links.Count)" -ForegroundColor Cyan
    Write-Host "Downloading: $url" -ForegroundColor Gray
    Write-Host ""
    
    & yt-dlp @defaultArgs @extraArgs $url
    
    Write-Host ""
}

Write-Host "Download completed." -ForegroundColor Green
Write-Host ""

# Rename files: strip brackets/noise from title, preserve [ytid]
Write-Host "Cleaning filenames..." -ForegroundColor Yellow
$renamed = 0
Get-ChildItem "downloads\*.mp3" | ForEach-Object {
    $original = $_.Name
    $cleaned  = (Get-CleanFilename $_.BaseName) + $_.Extension

    if ($cleaned -ne $original) {
        $dest = Join-Path $_.DirectoryName $cleaned
        if (-not (Test-Path $dest)) {
            Rename-Item $_.FullName $dest
            Write-Host "  $original" -ForegroundColor DarkGray
            Write-Host "  -> $cleaned" -ForegroundColor Gray
            $renamed++
        } else {
            Write-Host "  SKIP (conflict): $cleaned" -ForegroundColor Yellow
        }
    }
}
if ($renamed -eq 0) {
    Write-Host "  No renames needed." -ForegroundColor DarkGray
}
Write-Host ""
Write-Host "Your files are in the ""downloads"" folder" -ForegroundColor Green
Write-Host ""

# Clean up
Remove-Item "links.json" -Force -ErrorAction SilentlyContinue
Write-Host "links.json has been deleted." -ForegroundColor Gray
