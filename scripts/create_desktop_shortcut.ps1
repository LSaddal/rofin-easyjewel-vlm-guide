# create_desktop_shortcut.ps1  (PowerShell 2.0 compatible, works on Windows 7)
# Creates a LASER shortcut to the CORRECT VLM install and moves old shortcuts
# that point to a second VLM in Program Files out of the way (nothing is deleted).
$ErrorActionPreference = 'Stop'
$bin = 'C:\Rofin\VisualLaserMarker\Bin'      # change if needed
$exe = Join-Path $bin 'VisualLaserMarker.exe'
if (-not (Test-Path $exe)) { Write-Host "ERROR: $exe not found. Nothing was changed."; exit 1 }
$sh = New-Object -ComObject WScript.Shell
$desk = [Environment]::GetFolderPath('Desktop')

$l = $sh.CreateShortcut((Join-Path $desk 'LASER.lnk'))
$l.TargetPath = $exe
$l.WorkingDirectory = $bin
$l.IconLocation = "$exe,0"
$l.Description = 'Visual Laser Marker (correct install)'
$l.Save()
Write-Host "  OK  LASER shortcut created on the desktop"

$dest = 'C:\Rofin\old_shortcuts'
if (-not (Test-Path $dest)) { New-Item -ItemType Directory -Path $dest | Out-Null }
$places = @($desk, (Join-Path $env:PUBLIC 'Desktop'), [Environment]::GetFolderPath('Startup'))
$n = 0
foreach ($p in $places) {
  if (-not (Test-Path $p)) { continue }
  Get-ChildItem $p -Filter *.lnk | ForEach-Object {
    $t = $sh.CreateShortcut($_.FullName).TargetPath
    if ($t -like '*Program Files\VisualLaserMarker*' -or $t -like '*PROGRA~1\VISUAL~1*') {
      try { Move-Item $_.FullName $dest -Force; Write-Host "  moved to $dest : $($_.Name)"; $n++ }
      catch { Write-Host "  could not move (no rights): $($_.Name)" }
    }
  }
}
if ($n -eq 0) { Write-Host '  no old shortcuts found' }
Write-Host 'Done. Close VLM and double-click LASER on the desktop.'
