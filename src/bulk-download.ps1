[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

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
Write-Host "Your files are in the ""downloads"" folder" -ForegroundColor Green
Write-Host ""

# Clean up
Remove-Item "links.json" -Force -ErrorAction SilentlyContinue
Write-Host "links.json has been deleted." -ForegroundColor Gray
