@echo off
chcp 65001 > nul

setlocal EnableExtensions EnableDelayedExpansion

echo Bulk YouTube to MP3 Downloader
echo by mandrock0 (based on work EDM115)
echo.
echo Checking requirements...
call :require_cmd yt-dlp || goto :fatal
call :require_cmd ffmpeg || goto :fatal
call :require_cmd ffprobe || goto :fatal

if not exist "links.json" (
  echo ERROR: links.json not found in "%CD%"
  goto :fatal
)

if not exist "downloads\" (
  mkdir "downloads" >nul 2>&1
)

echo All requirements met.
echo.

if not "%~1"=="" (
  echo Extra yt-dlp args detected (they override defaults if duplicated):
  echo    %*
  echo.
)

echo Parsing links.json...
set count=0

for /f "usebackq delims=" %%A in ("links.json") do (
  set "line=%%A"

  rem Remove indentation/whitespace, quotes, and trailing commas
  set "line=!line: =!"
  set "line=!line:"=!"
  set "line=!line:,=!"

  rem Skip empty/brackets
  if not "!line!"=="" if /i not "!line!"=="[" if /i not "!line!"=="]" (
    set /a count+=1
    set "url[!count!]=!line!"
  )
)

if !count! EQU 0 (
  echo ERROR: No URLs found in links.json
  goto :fatal
)

echo Found !count! links
echo.

set DEFAULT_ARGS=-f "bestaudio/best"  --extract-audio --audio-format mp3 --audio-quality 0 --embed-subs --embed-thumbnail --embed-metadata --embed-chapters --windows-filenames --progress --console-title -o "downloads\%%(title)s [%%(id)s].%%(ext)s"

for /l %%i in (1,1,!count!) do (
  echo Processing link %%i/!count!
  set "current_url=!url[%%i]!"
  set "current_url=!current_url:"=!"
  set "current_url=!current_url:,=!"
  echo Downloading !current_url!
  echo.

  yt-dlp %DEFAULT_ARGS% %* "!current_url!"
  echo.
)

echo Download completed.
echo Your files are in the "downloads" folder
echo.
echo.
del /f /q "links.json" >nul 2>&1
pause
endlocal
exit /b 0

:require_cmd
where /q %~1 >nul 2>&1
if errorlevel 1 (
  echo ERROR: "%~1" not found in PATH
  echo Tip: add the folder containing %~1.exe to your PATH
  exit /b 1
)
echo Found %~1
exit /b 0

:fatal
echo.
echo Exiting...
pause
endlocal
exit /b 1
