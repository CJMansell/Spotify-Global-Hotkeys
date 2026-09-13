$spotify = $null
$type = $null

# -------------------------------------------------
# 1. Standard Spotify desktop installation
# -------------------------------------------------

$desktopPaths = @(
    "$env:APPDATA\Spotify\Spotify.exe",
    "$env:LOCALAPPDATA\Spotify\Spotify.exe",
    "$env:ProgramFiles\Spotify\Spotify.exe",
    "${env:ProgramFiles(x86)}\Spotify\Spotify.exe"
)

foreach ($path in $desktopPaths) {
    if ($path -and (Test-Path $path)) {
        $spotify = $path
        $type = "desktop"
        break
    }
}

# -------------------------------------------------
# 2. Registry search
# -------------------------------------------------

if (-not $spotify) {

    $registryPaths = @(
        "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*",
        "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*",
        "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
    )

    foreach ($regPath in $registryPaths) {

        $apps = Get-ItemProperty $regPath -ErrorAction SilentlyContinue |
            Where-Object {
                $_.DisplayName -like "*Spotify*"
            }

        foreach ($app in $apps) {

            if ($app.InstallLocation) {

                $candidate = Join-Path $app.InstallLocation "Spotify.exe"

                if (Test-Path $candidate) {
                    $spotify = $candidate
                    $type = "desktop"
                    break
                }
            }
        }

        if ($spotify) {
            break
        }
    }
}

# -------------------------------------------------
# 3. Microsoft Store Spotify
# -------------------------------------------------

$storePackage = Get-AppxPackage |
    Where-Object {
        $_.Name -like "*Spotify*"
    } |
    Select-Object -First 1

if (-not $spotify -and $storePackage) {

    $spotify = "spotify:"
    $type = "store"
}

# -------------------------------------------------
# Output
# -------------------------------------------------

$result = @{
    found = ($null -ne $spotify)
    type = $type
    launchTarget = $spotify
}

$result | ConvertTo-Json