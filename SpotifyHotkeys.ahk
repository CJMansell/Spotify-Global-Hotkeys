#Requires AutoHotkey v2.0
#SingleInstance Force

; ============================================================
; Spotify Package - Global Hotkeys
; ============================================================

PackageDir := A_ScriptDir

; SoundVolumeView bundled with package
SVV := PackageDir "\soundvolumeview-x64\SoundVolumeView.exe"

; ------------------------------------------------------------
; Verify SoundVolumeView exists
; ------------------------------------------------------------

if !FileExist(SVV)
{
    MsgBox(
        "SoundVolumeView.exe could not be found.`n`nExpected location:`n" SVV,
        "Spotify Hotkeys - Error",
        "Iconx"
    )

    ExitApp
}

; ------------------------------------------------------------
; Check Spotify every second
; Exit hotkeys when Spotify closes
; ------------------------------------------------------------

SetTimer(CheckSpotify, 1000)

CheckSpotify()
{
    if !ProcessExist("Spotify.exe")
        ExitApp
}

; ============================================================
; GLOBAL HOTKEYS
; ============================================================

; Ctrl + Alt + Space = Play / Pause
^!Space::
{
    Send "{Media_Play_Pause}"
}

; Ctrl + Alt + Right = Next Track
^!Right::
{
    Send "{Media_Next}"
}

; Ctrl + Alt + Left = Previous Track
^!Left::
{
    Send "{Media_Prev}"
}

; Ctrl + Alt + Up = Spotify Volume +5%
^!Up::
{
    Run(
        '"' SVV '" /ChangeVolume "Spotify.exe" 5',
        ,
        "Hide"
    )
}

; Ctrl + Alt + Down = Spotify Volume -5%
^!Down::
{
    Run(
        '"' SVV '" /ChangeVolume "Spotify.exe" -5',
        ,
        "Hide"
    )
}