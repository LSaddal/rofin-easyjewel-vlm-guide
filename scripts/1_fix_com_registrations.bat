@echo off
REM ==========================================================================
REM  1_fix_com_registrations.bat
REM  Re-registers the Visual Laser Marker COM components from the CORRECT
REM  install folder (default C:\Rofin\VisualLaserMarker\Bin).
REM  Use when VLM / EasyJewel crashes on 'Initialize hardware' because a
REM  second (older) VLM install hijacked the COM registrations.
REM  Makes a full backup of HKLM\SOFTWARE\Classes first.
REM  USE AT YOUR OWN RISK. Not affiliated with Rofin / Coherent.
REM ==========================================================================
title Fix VLM COM registrations
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
set BIN=C:\Rofin\VisualLaserMarker\Bin
set BACKUPDIR=C:\Rofin

set LOG="%~dp0fix1_result.txt"
echo Fix VLM COM registrations %date% %time% > %LOG%
if not exist "%BIN%\VisualLaserMarker.exe" (
  echo  VisualLaserMarker.exe not found in %BIN% - edit BIN at the top of this script.
  pause
  exit /b
)
echo.
echo Step 1: backing up HKLM\SOFTWARE\Classes (can take 1-2 minutes)...
reg export HKLM\SOFTWARE\Classes "%BACKUPDIR%\backup_classes_before_fix.reg" /y >> %LOG% 2>&1
if errorlevel 1 (
  echo  BACKUP FAILED - nothing was changed.
  pause
  exit /b
)
echo  Backup saved: %BACKUPDIR%\backup_classes_before_fix.reg
echo.
echo Step 2: registering components from %BIN% ...
if exist "%BIN%\MicoServer.dll" (
  regsvr32 /s "%BIN%\MicoServer.dll"
  if errorlevel 1 (echo  FAIL    MicoServer.dll & echo FAIL MicoServer.dll >> %LOG%) else (echo  OK      MicoServer.dll & echo OK MicoServer.dll >> %LOG%)
) else (echo  MISSING MicoServer.dll & echo MISSING MicoServer.dll >> %LOG%)
if exist "%BIN%\Power.dll" (
  regsvr32 /s "%BIN%\Power.dll"
  if errorlevel 1 (echo  FAIL    Power.dll & echo FAIL Power.dll >> %LOG%) else (echo  OK      Power.dll & echo OK Power.dll >> %LOG%)
) else (echo  MISSING Power.dll & echo MISSING Power.dll >> %LOG%)
if exist "%BIN%\bll.dll" (
  regsvr32 /s "%BIN%\bll.dll"
  if errorlevel 1 (echo  FAIL    bll.dll & echo FAIL bll.dll >> %LOG%) else (echo  OK      bll.dll & echo OK bll.dll >> %LOG%)
) else (echo  MISSING bll.dll & echo MISSING bll.dll >> %LOG%)
if exist "%BIN%\JobControl.dll" (
  regsvr32 /s "%BIN%\JobControl.dll"
  if errorlevel 1 (echo  FAIL    JobControl.dll & echo FAIL JobControl.dll >> %LOG%) else (echo  OK      JobControl.dll & echo OK JobControl.dll >> %LOG%)
) else (echo  MISSING JobControl.dll & echo MISSING JobControl.dll >> %LOG%)
if exist "%BIN%\LMOSAuto.dll" (
  regsvr32 /s "%BIN%\LMOSAuto.dll"
  if errorlevel 1 (echo  FAIL    LMOSAuto.dll & echo FAIL LMOSAuto.dll >> %LOG%) else (echo  OK      LMOSAuto.dll & echo OK LMOSAuto.dll >> %LOG%)
) else (echo  MISSING LMOSAuto.dll & echo MISSING LMOSAuto.dll >> %LOG%)
if exist "%BIN%\Spinner.dll" (
  regsvr32 /s "%BIN%\Spinner.dll"
  if errorlevel 1 (echo  FAIL    Spinner.dll & echo FAIL Spinner.dll >> %LOG%) else (echo  OK      Spinner.dll & echo OK Spinner.dll >> %LOG%)
) else (echo  MISSING Spinner.dll & echo MISSING Spinner.dll >> %LOG%)
if exist "%BIN%\vlmps.dll" (
  regsvr32 /s "%BIN%\vlmps.dll"
  if errorlevel 1 (echo  FAIL    vlmps.dll & echo FAIL vlmps.dll >> %LOG%) else (echo  OK      vlmps.dll & echo OK vlmps.dll >> %LOG%)
) else (echo  MISSING vlmps.dll & echo MISSING vlmps.dll >> %LOG%)
if exist "%BIN%\UniEdit.dll" (
  regsvr32 /s "%BIN%\UniEdit.dll"
  if errorlevel 1 (echo  FAIL    UniEdit.dll & echo FAIL UniEdit.dll >> %LOG%) else (echo  OK      UniEdit.dll & echo OK UniEdit.dll >> %LOG%)
) else (echo  MISSING UniEdit.dll & echo MISSING UniEdit.dll >> %LOG%)
if exist "%BIN%\FoilControl_1_2.dll" (
  regsvr32 /s "%BIN%\FoilControl_1_2.dll"
  if errorlevel 1 (echo  FAIL    FoilControl_1_2.dll & echo FAIL FoilControl_1_2.dll >> %LOG%) else (echo  OK      FoilControl_1_2.dll & echo OK FoilControl_1_2.dll >> %LOG%)
) else (echo  MISSING FoilControl_1_2.dll & echo MISSING FoilControl_1_2.dll >> %LOG%)
if exist "%BIN%\logogen.dll" (
  regsvr32 /s "%BIN%\logogen.dll"
  if errorlevel 1 (echo  FAIL    logogen.dll & echo FAIL logogen.dll >> %LOG%) else (echo  OK      logogen.dll & echo OK logogen.dll >> %LOG%)
) else (echo  MISSING logogen.dll & echo MISSING logogen.dll >> %LOG%)
if exist "%BIN%\dbdal.dll" (
  regsvr32 /s "%BIN%\dbdal.dll"
  if errorlevel 1 (echo  FAIL    dbdal.dll & echo FAIL dbdal.dll >> %LOG%) else (echo  OK      dbdal.dll & echo OK dbdal.dll >> %LOG%)
) else (echo  MISSING dbdal.dll & echo MISSING dbdal.dll >> %LOG%)
if exist "%BIN%\QueryProcess.dll" (
  regsvr32 /s "%BIN%\QueryProcess.dll"
  if errorlevel 1 (echo  FAIL    QueryProcess.dll & echo FAIL QueryProcess.dll >> %LOG%) else (echo  OK      QueryProcess.dll & echo OK QueryProcess.dll >> %LOG%)
) else (echo  MISSING QueryProcess.dll & echo MISSING QueryProcess.dll >> %LOG%)
if exist "%BIN%\VMCStandard.dll" (
  regsvr32 /s "%BIN%\VMCStandard.dll"
  if errorlevel 1 (echo  FAIL    VMCStandard.dll & echo FAIL VMCStandard.dll >> %LOG%) else (echo  OK      VMCStandard.dll & echo OK VMCStandard.dll >> %LOG%)
) else (echo  MISSING VMCStandard.dll & echo MISSING VMCStandard.dll >> %LOG%)
if exist "%BIN%\PowerGUI.dll" (
  regsvr32 /s "%BIN%\PowerGUI.dll"
  if errorlevel 1 (echo  FAIL    PowerGUI.dll & echo FAIL PowerGUI.dll >> %LOG%) else (echo  OK      PowerGUI.dll & echo OK PowerGUI.dll >> %LOG%)
) else (echo  MISSING PowerGUI.dll & echo MISSING PowerGUI.dll >> %LOG%)
if exist "%BIN%\MicoServerEx.exe" (
  "%BIN%\MicoServerEx.exe" /regserver
  if errorlevel 1 (echo  FAIL    MicoServerEx.exe & echo FAIL MicoServerEx.exe >> %LOG%) else (echo  OK      MicoServerEx.exe & echo OK MicoServerEx.exe >> %LOG%)
)
echo.
echo Done. A log is in fix1_result.txt next to this script.
echo Start VLM from %BIN% and try Initialize hardware.
echo If VLM now complains about PCLD / PC card, run 2_fix_vlm_paths.bat.
echo.
pause
