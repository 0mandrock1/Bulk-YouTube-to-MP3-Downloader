# YouTube to MP3 Bulk Downloader

A batch script utility for downloading multiple YouTube videos as MP3 files with metadata.

## Requirements

- Windows OS
- [yt-dlp](https://github.com/yt-dlp/yt-dlp)
- [ffmpeg](https://ffmpeg.org/)
- [ffprobe](https://ffprobe.org/)

All three tools must be available in your system PATH.

## Installation

1. Ensure all requirements are installed and added to PATH
2. Clone or download this repository
3. Place the scripts in your desired directory

## Project Structure

```
ver2/
├── add-links.bat                    # Main script for adding links
├── bulk-youtube-download-mp3.bat    # Main script for downloading
├── links.json                       # Auto-generated link queue
├── README.md
├── downloads/                       # Output folder for downloaded MP3s
└── src/
    ├── add-links.ps1                # Link manager (PowerShell)
    └── bulk-download.ps1            # Downloader (PowerShell)
```

## Usage

### Step 1: Add Links

Run `add-links.bat` to add YouTube links to the queue:

```batch
add-links.bat
```

**First**, choose an option:
- **Option 1** - Create new file (clears existing links)
- **Option 2** - Add links to existing file (append mode)

**Then**, enter YouTube links one by one:
- Link must be from YouTube (`youtube.com` or `youtu.be`)
- Duplicate links are automatically rejected
- Supports links with query parameters: `https://youtu.be/tXug39t8lx4?si=...`
- Special characters like `&`, `?`, `%` are handled correctly

**Exit** the script by typing:
- `N` - Finish and save
- `exit`, `quit`, `q`, `e` - Quit without saving

A `links.json` file will be created with all valid YouTube links in JSON format.

### Step 2: Download

Run `bulk-youtube-download-mp3.bat` to download all queued links:

```batch
bulk-youtube-download-mp3.bat
```

Or with additional yt-dlp arguments:

```batch
bulk-youtube-download-mp3.bat --audio-quality 192
```

**Features:**
- Automatic JSON parsing from `links.json` (supports new JSON format)
- **Playlist support** - automatically downloads all videos from playlists
- Downloads best available audio quality
- Embeds subtitles, thumbnails, and metadata
- Creates `downloads/` folder automatically
- Displays download progress
- Cleans up `links.json` after completion

## Output

All downloaded MP3 files are saved to the `downloads/` folder with format:
```
downloads/[video-title] [video-id].mp3
```

## Options

You can pass additional yt-dlp arguments. Common options:

- `--audio-quality 128` - Set audio quality (default: 0/best)
- Windows-compatible paths and filenames are used automatically

## Notes

- The script validates that all required tools are installed
- `links.json` is automatically deleted after processing
- Empty links are rejected during input
- Compatible with Windows terminal encoding (UTF-8)

## License

Based on work by EDM115 - https://github.com/EDM115/bulk-youtube-download
