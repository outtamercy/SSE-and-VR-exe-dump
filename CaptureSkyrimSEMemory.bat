@echo off
setlocal
title SkyrimSE memory dump watcher

echo SkyrimSE dump watcher. It'll wait for the game, then grab memory after it settles.
echo Leave this window alone and go hit the main menu.
echo.

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0CaptureSkyrimSEMemory.ps1"

echo.
pause
