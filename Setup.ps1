$ErrorActionPreference = "Stop"

# -------------------------------------------------
# Package paths
# -------------------------------------------------

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$packageDir = Split-Path -Parent $scriptDir

$findSpotifyScript = Join-Path $scriptDir "FindSpotify.ps1"
$configPath = Join-Path $packageDir "config.json"

$soundVolumeViewPath = Join-Path $packageDir "soundvolumeview-x64\SoundVolumeView.exe"

# -------------------------------------------------
# Verify required files
# -------------------------------------------------

if (-not (Test-Path $findSpotifyScript)) {
    Write-Host "ERROR: FindSpotify.ps1 was not found."
    exit 1
}

if (-not (Test-Path $soundVolumeViewPath)) {
    Write-Host "ERROR: SoundVolumeView.exe was not found."
    exit 1
}

# -------------------------------------------------
# Find Spotify
# -------------------------------------------------

$spotifyJson = & $findSpotifyScript
$spotify = $spotifyJson | ConvertFrom-Json

if (-not $spotify.found) {
    Write-Host "ERROR: Spotify could not be found."
    exit 1
}

# -------------------------------------------------
# Build config
# -------------------------------------------------

$config = [ordered]@{
    spotify = [ordered]@{
        found        = $spotify.found
        type         = $spotify.type
        launchTarget = $spotify.launchTarget
    }

    soundVolumeViewPath = $soundVolumeViewPath
    volumeStep          = 5
}

# -------------------------------------------------
# Write config.json
# -------------------------------------------------

$config |
    ConvertTo-Json -Depth 5 |
    Set-Content -Path $configPath -Encoding UTF8

# -------------------------------------------------
# Output result
# -------------------------------------------------

Write-Host ""
Write-Host "Setup complete."
Write-Host ""
Write-Host "Spotify type: $($spotify.type)"
Write-Host "Spotify target: $($spotify.launchTarget)"
Write-Host "SoundVolumeView: $soundVolumeViewPath"
Write-Host "Config written to: $configPath"
Write-Host ""