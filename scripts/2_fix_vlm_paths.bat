@echo off
REM ==========================================================================
REM  2_fix_vlm_paths.bat
REM  Points VLM back to the CORRECT install folder and power database.
REM  Use when VLM starts but says it uses a PC card (PCLD) instead of the
REM  network RCU, or never connects to the laser.
REM  Backs up the keys it changes first.
REM  USE AT YOUR OWN RISK. Not affiliated with Rofin / Coherent.
REM ==========================================================================
title Fix VLM settings folder
net session >nul 2>&1
if errorlevel 1 (
  echo.
  echo  THIS SCRIPT MUST RUN AS ADMINISTRATOR.
  echo  Right-click the .bat file and choose "Run as administrator".
  echo.
  pause
  exit /b
)

REM --- Change this if your working VLM lives somewhere else ---
set VLMDIR=C:\Rofin\VisualLaserMarker
set BACKUPDIR=C:\Rofin

set LOG="%~dp0fix2_result.txt"
echo Fix VLM paths %date% %time% > %LOG%
if not exist "%VLMDIR%\System\Registry.xml" (
  echo  %VLMDIR%\System\Registry.xml not found - edit VLMDIR at the top of this script.
  pause
  exit /b
)
echo.
echo Step 1: backups...
reg export "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\VLM.exe" "%BACKUPDIR%\backup_apppath_vlm.reg" /y >> %LOG% 2>&1
reg export HKCU\Software\ODBC\ODBC.INI "%BACKUPDIR%\backup_odbc.reg" /y >> %LOG% 2>&1
if errorlevel 1 (
  echo  BACKUP FAILED - nothing was changed.
  pause
  exit /b
)
echo  Backups saved in %BACKUPDIR%
echo.
echo Step 2: pointing VLM to %VLMDIR% ...
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\VLM.exe" /v Path /t REG_SZ /d "%VLMDIR%" /f >> %LOG% 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\VLM.exe" /ve /t REG_SZ /d "%VLMDIR%\Bin\VisualLaserMarker.exe" /f >> %LOG% 2>&1
if exist "%VLMDIR%\System\rspower3.mdb" reg add HKCU\Software\ODBC\ODBC.INI\RSPOWER3 /v DBQ /t REG_SZ /d "%VLMDIR%\System\rspower3.mdb" /f >> %LOG% 2>&1
echo.
echo Step 3: check (both should show %VLMDIR%):
reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\VLM.exe"
reg query HKCU\Software\ODBC\ODBC.INI\RSPOWER3 /v DBQ
echo.
echo Done. Close VLM if it is open, start it again from %VLMDIR%\Bin
echo and try Initialize hardware.
echo.
pause
