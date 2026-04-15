@echo off
chcp 65001 > nul
setlocal enabledelayedexpansion

(
    echo [
    echo ]
) > links.json

echo.
echo === Adding links to links.json ===
echo (to finish enter N)
echo.

set first=1

:loop
set /p link="Enter link: "

if /i "%link%"=="N" (
    echo.
    echo Done. Links saved to links.json
    goto finalize
)

if "%link%"=="" (
    echo Error: link cannot be empty
    goto loop
)

echo %link% | findstr /i "http" > nul
if errorlevel 1 (
    echo.
    echo Done. Links saved to links.json
    goto finalize
)

if !first!==1 (
    (
        echo [
        echo     "!link!"
    ) > links.json
    set first=0
) else (
    (
        for /f "delims=" %%i in (links.json) do (
            if not "%%i"=="]" (
                echo %%i
            )
        )
        echo     ,"!link!"
    ) > links.json.tmp
    move /y links.json.tmp links.json > nul
)

goto loop

:finalize
(
    for /f "delims=" %%i in (links.json) do (
        if not "%%i"=="]" (
            echo %%i
        )
    )
    echo ]
) > links.json.tmp
move /y links.json.tmp links.json > nul

endlocal
pause
