$ErrorActionPreference = "Stop"
function write-header ([string]$text){
    Write-Output ""
    Write-Output "########################################"
    Write-Output "  $text"
    Write-Output "########################################"
    Write-Output ""
}

$url = "https://github.com/aseprite/aseprite.git"

$start_time = Get-Date

# get the aseprite repo
write-header "Cloning aseptire repo"

# check if the repo is already cloned
if ((Test-Path $env:ASEPRITE_REPO) -eq $false) {
    $latestTag = ""
    if ($null -eq $args[0]) {
        Write-Output "Getting the latest tag:"
        $latestTag = (git -c 'versionsort.suffix=-' ls-remote --tags --sort='v:refname' $url '*.*' | Select-Object -Last 1).split('')[1] -replace "refs/tags/",""
        Write-Output "  $latestTag"
    }
    elseif ($args[0] -eq "master") {
        Write-Output "Using master"
        $latestTag = "master"
    }
    else {
        $latestTag = $args[0]
    }
    
    # cloning the repo
    #Start-Process -FilePath "git" -ArgumentList "clone", "--recursive", $url -NoNewWindow -Wait
    git clone --recursive -b $latestTag --single-branch $url $env:ASEPRITE_REPO
}
else {
    Write-Output "Already cloned..."
}


write-header "Getting the Skia pre-built binary"
if ((Test-Path $env:ASEPRITE_DEPS) -eq $false) {
    $skia = Invoke-WebRequest 'https://api.github.com/repos/aseprite/skia/releases/latest' -UseBasicParsing | Convertfrom-json
    $assetUrl = $null
    $assetName = $null
    foreach ($asset in $skia.assets) {
        if ($asset.name -like '*Windows-Release-x64*') {
            $assetUrl = $asset.browser_download_url
            $assetName = $asset.name
        }
    }
    
    if ($null -eq $assetUrl) {
        throw "Could not find a windows x64 release!"
    }
    
    # download skia
    $output = "$($env:ASEPRITE_TEMP)\$assetName"
    (New-Object System.Net.WebClient).DownloadFile($assetUrl, $output)
    
    New-Item -Path $env:ASEPRITE_DEPS -Name "skia" -ItemType "directory" | Out-Null
    
    $skiaLocation = "$($env:ASEPRITE_DEPS)\skia"
    # extract skia into the deps folder
    Expand-Archive -LiteralPath $output -DestinationPath $skiaLocation
}
else {
    Write-Output "Already downloaded..."
}

if ((Test-Path "$($env:ASEPRITE_REPO)\build") -eq $false) {
    New-Item -Path $env:ASEPRITE_REPO -Name "build" -ItemType "directory" | Out-Null
}
Set-Location "$($env:ASEPRITE_REPO)\build"

write-header "Running cmake"
Start-Process -FilePath "cmake" -ArgumentList "-DCMAKE_BUILD_TYPE=RelWithDebInfo", "-DLAF_BACKEND=skia", "-DSKIA_DIR='$skiaLocation'", "-DSKIA_LIBRARY_DIR='$skiaLocation\out\Release-x64'", "-DSKIA_LIBRARY='$skiaLocation\out\Release-x64\skia.lib'", "-G Ninja", ".." -NoNewWindow -Wait

write-header "Building with ninja"
Start-Process -FilePath "ninja" -ArgumentList "aseprite" -NoNewWindow -Wait

write-header "Copying files to the dist directory"
Copy-Item -Path "$($env:ASEPRITE_REPO)\build\bin\*" -Destination $env:ASEPRITE_DIST -Exclude "*.pdb" -Recurse
$copiedFilesInfo = (Get-ChildItem -Path $env:ASEPRITE_DIST -Recurse | Measure-Object -Property Length -sum)
Write-Output "Files copied:"
if ($null -ne $copiedFilesInfo) {
    Write-Output "  $($copiedFilesInfo.Count) ($([math]::Round($copiedFilesInfo.sum / 1Mb, 2))Mb)"
}
else {
    Write-Output "  - none -"
}

Write-Output ""
Write-Output "#####################################################"
Write-Output "  IF YOU LIKE ASEPRITE PLEASE SUPPORT THE CREATORS!"
Write-Output "        https://www.aseprite.org/download/"
Write-Output "#####################################################"
Write-Output ""
Write-Output "DONE! ($((Get-Date).Subtract($start_time).ToString()) seconds)"
Write-Output ""
