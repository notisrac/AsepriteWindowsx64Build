## Introduction
Docker image for building Aseprite for Windows x64
It can be used to build Aseprite then exit, or as a build environment.

## Build the image
```cmd
docker build -t aseprite_win_x64:latest -m 2GB .
```

## Build Aseprite
In this mode the image will clone, build and copy Aseprite into the dist folder.
```cmd
docker run -it --volume <local dir>:C:/dist --name aseprite_win_x64 aseprite_win_x64:latest
```
Where ```<local dir>``` is a folder to put the built files
_Note: during execution, the process might appear frozen for minutes, please be patient :)_

## Get a console
In this mode you will get a console, from where you can run the build manually
```cmd
docker run -it --volume <local dir>:C:/dist --name aseprite_win_x64 --env CONSOLE=true aseprite_win_x64:latest
```
Where ```<local dir>``` is a folder to put the built files

 - To exit from the container and shut it down just type ```exit```
 - To detach from the container and leave it running use the ```CTRL-p CTRL-q``` key sequence
 - To access it later:
  - If it is not running, then start it with ```docker start aseprite_win_x64```
  - Attach to it with ```docker attach aseprite_win_x64```

## Folder structure
```
C:\
  + aseprite             # the source code
   - build               # the working directory of the build
  + BuildTools           # the visual studio build tools
  + dist                 # the compiled files will be copied here
  + deps                 # skia and the dependencies are here
  + TEMP                 # the temp folder
   - choco_install.ps1   # chocolatey install script
   - run.bat             # handles the console mode
   - vs_buildtools.exe   # visual studio installer
  + TOOLS                # tools for building
   - build.ps1           # this script runs the build procedure
```

## TODO
- [x] Create the image
- [x] Create a script to fetch and build aseprite
- [x] Use ~~nanoserver~~ powershell image, as the .NET SDK is not needed (nanoserver does not contain powershell, but it is mandatory!)
- [x] Parameterize all the paths
- [x] Aseprite version must be selectable from parameter - at least latest release and dev (as selecting a too old version will introduce problems with the dependencies)
- [ ] Add a cli file editor to the image (```choco install nano```) - _nano does - not run well in a container, see: https://github.com/moby/moby/issues/8755_
- [ ] Add a cli file manager to the image (```choco install mc```)
- [ ] Clean up after/before build