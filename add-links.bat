@echo off
chcp 65001 > nul
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0src\add-links.ps1"
pause

