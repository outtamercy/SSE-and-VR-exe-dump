@echo off
setlocal
title SkyrimVR memory dump watcher

echo SkyrimVR dump watcher. It'll wait for the game, then grab memory after it settles.
echo Leave this window alone and go do VR stuff.
echo.

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0CaptureSkyrimVRMemory.ps1"

echo.
pause
