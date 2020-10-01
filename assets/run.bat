@echo off

IF "%CONSOLE%"=="true" (
    echo starting console
    Powershell.exe -NoLogo -ExecutionPolicy Bypass
) ELSE (
    echo starting build
    Powershell.exe -NoLogo -ExecutionPolicy Bypass -File %ASEPRITE_TOOLS%\build.ps1 %*
)
