$ErrorActionPreference = "Stop"

# ============================================================
# SPOTIFY HOTKEY PACKAGE - LAUNCHER
# ============================================================

# ------------------------------------------------------------
# Resolve package paths
# ------------------------------------------------------------

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$packageDir = Split-Path -Parent $scriptDir

$configPath    = Join-Path $packageDir "config.json"
$setupScript   = Join-Path $scriptDir "Setup.ps1"
$hotkeyProgram = Join-Path $packageDir "SpotifyHotkeys.exe"

# ------------------------------------------------------------
# Make sure config exists
# ------------------------------------------------------------

if (-not (Test-Path $configPath)) {

    Write-Host "Config not found. Running setup..."

    if (-not (Test-Path $setupScript)) {
        Write-Host "ERROR: Setup.ps1 was not found."
        exit 1
    }

    & $setupScript
}

# ------------------------------------------------------------
# Load config
# ------------------------------------------------------------

$config = Get-Content $configPath -Raw | ConvertFrom-Json

if (-not $config.spotify.found) {
    Write-Host "ERROR: Spotify was not found."
    exit 1
}

# ------------------------------------------------------------
# Recheck desktop Spotify path
# ------------------------------------------------------------

if ($config.spotify.type -eq "desktop") {

    if (-not (Test-Path $config.spotify.launchTarget)) {

        Write-Host "Saved Spotify path is invalid."
        Write-Host "Running setup again..."

        & $setupScript

        $config = Get-Content $configPath -Raw | ConvertFrom-Json
    }
}

# ============================================================
# WINDOWS API
# ============================================================

if (-not ("SpotifyWindowToolsV2" -as [type])) {

    Add-Type @"
using System;
using System.Runtime.InteropServices;

public class SpotifyWindowToolsV2
{
    [DllImport("user32.dll")]
    public static extern bool SetForegroundWindow(IntPtr hWnd);

    [DllImport("user32.dll")]
    public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
}
"@

}

# ============================================================
# CHECK WHETHER SPOTIFY IS ALREADY RUNNING
# ============================================================

$spotifyProcess = Get-Process Spotify -ErrorAction SilentlyContinue |
    Where-Object { $_.MainWindowHandle -ne 0 } |
    Select-Object -First 1

# ============================================================
# LAUNCH SPOTIFY IF NEEDED
# ============================================================

if (-not $spotifyProcess) {

    Write-Host "Spotify is not running. Starting Spotify..."

    if ($config.spotify.type -eq "store") {

        Start-Process $config.spotify.launchTarget

    }
    elseif ($config.spotify.type -eq "desktop") {

        Start-Process $config.spotify.launchTarget

    }
    else {

        Write-Host "ERROR: Unknown Spotify installation type."
        exit 1
    }

}
else {

    Write-Host "Spotify is already running."
}

# ============================================================
# WAIT FOR SPOTIFY WINDOW
# ============================================================

Write-Host "Waiting for Spotify window..."

$spotifyProcess = $null

# Up to 45 seconds
for ($i = 0; $i -lt 180; $i++) {

    $spotifyProcesses = Get-Process Spotify -ErrorAction SilentlyContinue

    foreach ($process in $spotifyProcesses) {

        $process.Refresh()

        if ($process.MainWindowHandle -ne 0) {

            $spotifyProcess = $process
            break
        }
    }

    if ($spotifyProcess) {
        break
    }

    Start-Sleep -Milliseconds 250
}

if (-not $spotifyProcess) {

    Write-Host "ERROR: Spotify main window was not found."
    exit 1
}

Write-Host "Spotify window detected."

# ============================================================
# RESTORE SPOTIFY
# ============================================================

# SW_RESTORE = 9
[SpotifyWindowToolsV2]::ShowWindow(
    $spotifyProcess.MainWindowHandle,
    9
) | Out-Null

Start-Sleep -Milliseconds 1500

# ============================================================
# ACTIVATE SPOTIFY
# ============================================================

$wshell = New-Object -ComObject WScript.Shell

$activated = $false

for ($attempt = 0; $attempt -lt 20; $attempt++) {

    [SpotifyWindowToolsV2]::SetForegroundWindow(
        $spotifyProcess.MainWindowHandle
    ) | Out-Null

    $activated = $wshell.AppActivate($spotifyProcess.Id)

    if ($activated) {
        break
    }

    Start-Sleep -Milliseconds 250
}

if (-not $activated) {

    Write-Host "ERROR: Could not activate the Spotify window."
    exit 1
}

Write-Host "Spotify activated."

Start-Sleep -Milliseconds 1500

# ============================================================
# FORCE SPOTIFY INTERNAL VOLUME TO 100%
# ============================================================

Write-Host "Forcing Spotify internal volume to 100%..."

for ($i = 0; $i -lt 40; $i++) {

    $wshell.SendKeys("^{UP}")

    Start-Sleep -Milliseconds 60
}

Start-Sleep -Milliseconds 700

Write-Host "Spotify internal volume forced to maximum."

# ============================================================
# START GLOBAL HOTKEY PROGRAM
# ============================================================

if (-not (Test-Path $hotkeyProgram)) {

    Write-Host "ERROR: SpotifyHotkeys.exe was not found."
    Write-Host "Expected location:"
    Write-Host $hotkeyProgram
    exit 1
}

# Don't launch a second copy if it's already running
$existingHotkeys = Get-Process SpotifyHotkeys -ErrorAction SilentlyContinue

if (-not $existingHotkeys) {

    Start-Process $hotkeyProgram

    Write-Host "Spotify hotkeys started."
}
else {

    Write-Host "Spotify hotkeys are already running."
}

# ============================================================
# COMPLETE
# ============================================================

Write-Host ""
Write-Host "Spotify package ready."
Write-Host ""