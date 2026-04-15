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

## Usage

### Step 1: Add Links

Run `add-links.bat` to add YouTube links to the queue:

```batch
add-links.bat
```

- Prompted to enter links one by one
- Press Enter after each link
- Enter any text without "http" to finish (e.g., "N", "done", "exit")
- A `links.json` file will be created with all entered links
- You can add YouTube video links or playlist links

### Step 2: Download

Run `bulk-youtube-download-mp3.bat` to download all queued links:

```batch
bulk-youtube-download-mp3.bat
```

Or with additional yt-dlp arguments:

```batch
bulk-youtube-download-mp3.bat --audio-quality 192
```

### Features

- Automatic JSON parsing from `links.json`
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
