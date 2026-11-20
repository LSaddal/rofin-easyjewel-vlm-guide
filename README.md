# Rofin EasyJewel / EasyMark + Visual Laser Marker (VLM): troubleshooting guide

A field guide for getting an old **Rofin EasyJewel / EasyMark** fiber laser marker (E10-class, RCU control unit on the network, Windows 7 PC running **Visual Laser Marker / VLM**) working again after a PC crash, disk move or software reinstall.

Almost nothing about these machines can be found online. This guide was written after several weeks of troubleshooting one machine until it marked again. I hope it saves you that time.

> ⚠️ **Disclaimer.** This is not official Rofin/Coherent documentation. Everything here is done **at your own risk**. Lasers are dangerous: never run a job with the door open, keep the emergency stop within reach, and never open the laser source or high-voltage parts. Always make backups before changing anything. None of Rofin's software is included here, only small helper scripts.

---

## Symptoms this guide covers

Search-friendly list of what we saw:

- `Init Machine failed` in EasyJewel / VLM
- VLM **crashes** (closes or shows a .NET error) right after **Initialize hardware**
- VLM says it uses a **PCLD** / PC card driver instead of the network RCU, or never even tries to reach the laser
- `ali device` … `DD_STATUS_TIMEOUT` after a **Stop alarm**
- At laser power-on, the RCU shows **"RCU Update"** / **"SRAMDisk"** and waits for **OK**; the laser only spins its fans until you click it
- Windows says **"This copy of Windows is not genuine"** after the disk was moved to a new PC (cosmetic, see below)

---

## The root cause (in our case)

**The laser hardware was fine.** The problem was on the PC.

Two copies of VLM were installed:

| Folder | Version | Status |
|---|---|---|
| `C:\Rofin\VisualLaserMarker` | 2012 build, configured for this machine | ✅ correct |
| `C:\Program Files\VisualLaserMarker` | 2008 build, installed later | ❌ wrong |

Installing the second (older) copy silently took over three things in Windows:

1. **COM registrations.** Many VLM components (`LaserCore`, `Power`, `JobControl`, `LMOSAuto`, `MicoServer`…) were registered from the *Program Files* folder. That made VLM **crash on Initialize hardware**.
2. **`App Paths\VLM.exe`** in the registry (`HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\VLM.exe`, value `Path`). VLM uses it to find its `System` folder. It pointed to *Program Files*, whose `System\Registry.xml` **has no `LaserControlType` setting**. VLM then falls back to **PCLD (PC card) mode** and never contacts the network RCU.
   The correct `Registry.xml` contains `LaserControlType = 1` (network RCU) and the right machine `.CFG`.
3. **ODBC data sources** (`HKCU\Software\ODBC\ODBC.INI`: `RSPOWER3`, `RSPOWER`, `MODATA`) pointed to the `.mdb` power databases in *Program Files*.

**Lesson:** if your machine came with VLM in `C:\Rofin`, **never install another VLM in Program Files**. Also don't simply delete it: uninstalling can remove shared registrations again. Instead, repair as below.

---

## Step-by-step fix

Do these in order and test VLM after each step. Run every `.bat` with **right-click → Run as administrator**. Each script makes a registry backup first and writes a log next to itself.

> If your working VLM is not in `C:\Rofin\VisualLaserMarker`, edit the path at the top of each script first.

### 0. Prerequisites
- **Visual C++ 2005 runtime (x86)** must be installed (`vcredist_x86.exe`, Microsoft). Without it VLM won't start at all.
- The **HASP** licence dongle service/driver must be running. If the disk came from another PC, the HASP driver sometimes has to be reinstalled. Do **not** try to bypass the licence.
- If you get a "security COM" error: register `UserAccess.dll` and `LMOSActX.ocx` from the `C:\Rofin` install with `regsvr32`.

### 1. VLM crashes on Initialize hardware → [`scripts/1_fix_com_registrations.bat`](scripts/1_fix_com_registrations.bat)
- Backs up `HKLM\SOFTWARE\Classes`.
- Re-registers 14 VLM components plus `MicoServerEx.exe` from the correct `Bin` folder.
- In our case the crash was gone after this. The next error was the PCLD message.

Also check `LaserCore.dll` and the OCX controls (`lucaocx`, `PowerGUI.ocx`, `RS_TextBox`, `qrmaker`) with `regsvr32` from the correct folder if the crash remains.

### 2. VLM talks about PCLD / never connects → [`scripts/2_fix_vlm_paths.bat`](scripts/2_fix_vlm_paths.bat)
- Backs up the `App Paths\VLM.exe` key and your ODBC data sources.
- Points `App Paths\VLM.exe` (both `Path` and the default value) to the correct install.
- Points the `RSPOWER3` ODBC source to the correct `System\rspower3.mdb`.

After this, VLM connected and the laser **marked again**. 🎉

### 3. Make it foolproof → [`scripts/3_create_desktop_shortcut.bat`](scripts/3_create_desktop_shortcut.bat)
- Creates a **LASER** desktop shortcut to the correct VLM.
- Moves old shortcuts that point to the Program Files copy into `C:\Rofin\old_shortcuts`. Nothing is deleted.
- This is handy when non-technical family members or colleagues use the machine.

---

## Network checks

The RCU (laser control unit) is a small Windows CE computer that talks to VLM over Ethernet. Our setup:

| Device | IP |
|---|---|
| RCU (laser) | `192.168.0.200` |
| PC | `192.168.0.2` / mask `255.255.255.0` |

Quick checks on the PC:

```bat
ping 192.168.0.200
arp -a
```

```powershell
# is the RCU's control port reachable?
(New-Object Net.Sockets.TcpClient).Connect('192.168.0.200', 10050)
```

While VLM is connected, `netstat -an | find "192.168.0.200"` shows `ESTABLISHED` connections.

The RCU also exposes **anonymous FTP** with its log files (`log.1.txt`; `log.txt` is locked while running). This is useful to see what the controller itself complains about. Only read; don't change files on the RCU.

> Tip: keep this PC **offline** (no internet). It runs Windows 7, which gets no security updates anymore.

---

## Daily use: start order matters

1. Turn on the **PC first** and wait for Windows.
2. Then turn on the **laser**. If the RCU shows **"RCU Update / SRAMDisk"**, click **OK** on the PC screen. Otherwise only the fans run.
   (This message likely comes from a weak RCU backup battery, because the RCU clock resets to 2008. It's harmless but annoying.)
3. Unlock (key/padlock button) and wait until the laser is ready.
4. Start VLM (the **LASER** shortcut). VLM connects at startup, so the laser must be ready **before** you start VLM.
5. Close the door and mark.
6. Shut down in reverse: VLM → laser → PC.

### "Stop alarm" / `DD_STATUS_TIMEOUT`
Close VLM, switch the laser **off**, wait 1 minute, switch it on, click OK, unlock, start VLM, then **Initialize hardware**. This fixed it every time for us.

---

## "This copy of Windows is not genuine"

If the PC's disk was moved to new hardware, Windows 7 loses its activation. This is **only cosmetic** for the laser: you get a black wallpaper and a pop-up. VLM works fine.
Click **Close**, and don't click "Go online" if the PC is offline. Proper fix: activate with a valid licence key. **Don't use "activators" or cracks**: they often contain malware.

---

## Useful log locations

- VLM log: `VLMLogger.log` in the VLM folder / `Trace` folder. Check the **dates**, because old sessions stay in the file.
- Crash dumps (`*.dmp`): exception `0xE0434F4D` = a .NET exception inside VLM, usually a missing or wrong COM registration.
- RCU logs: via FTP on the RCU, see above.

---

## Undo

Every script saves `.reg` backups in `C:\Rofin`. Double-click a backup `.reg` file to restore that registry state.

---

## Contributing

Have the same machine and found something else? Open an issue or pull request. Error messages, photos of screens and which VLM version you have are all very welcome.

## License

The scripts and text in this repository are MIT licensed. Rofin, EasyJewel, EasyMark and Visual Laser Marker are trademarks of their respective owners. This project is not affiliated with them.
