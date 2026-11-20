@echo off
title Create LASER desktop shortcut
echo Creating LASER shortcut on the desktop ...
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0create_desktop_shortcut.ps1"
pause
