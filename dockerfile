# escape=`

# Use the latest Windows Server Core image with .NET Framework 4.8.
# FROM mcr.microsoft.com/dotnet/framework/sdk:4.8-windowsservercore-ltsc2019
FROM mcr.microsoft.com/powershell:latest

# Restore the default Windows shell for correct batch processing.
SHELL ["cmd", "/S", "/C"]

ENV ASEPRITE_REPO "C:\aseprite"
ENV ASEPRITE_TEMP "C:\TEMP"
ENV ASEPRITE_DIST "C:\dist"
ENV ASEPRITE_TOOLS "C:\TOOLS"
ENV ASEPRITE_DEPS "C:\deps"


# Download the Build Tools bootstrapper.
ADD https://aka.ms/vs/16/release/vs_buildtools.exe ${ASEPRITE_TEMP}\vs_buildtools.exe

# Install the C++ Build Tools (this will install CMake as well), excluding workloads and components with known issues.
RUN %ASEPRITE_TEMP%\vs_buildtools.exe --quiet --wait --norestart --nocache `
    --installPath C:\BuildTools `
    --add Microsoft.VisualStudio.Workload.VCTools --includeRecommended `
    --add Microsoft.VisualStudio.Workload.NativeDesktop `
    --remove Microsoft.VisualStudio.Component.Windows10SDK.10240 `
    --remove Microsoft.VisualStudio.Component.Windows10SDK.10586 `
    --remove Microsoft.VisualStudio.Component.Windows10SDK.14393 `
    --remove Microsoft.VisualStudio.Component.Windows81SDK `
 || IF "%ERRORLEVEL%"=="3010" EXIT 0

# get the chocolatey install file
ADD https://chocolatey.org/install.ps1 ${ASEPRITE_TEMP}\choco_install.ps1

# install chocolatey
RUN powershell "& ""%ASEPRITE_TEMP%\choco_install.ps1"""

# install git with choco
RUN choco install -y git

# install ninja with choco
RUN choco install -y ninja

# Copy the startup batch file.
# COPY assets\run.bat ${ASEPRITE_TEMP}\
ADD https://raw.githubusercontent.com/notisrac/AsepriteWindowsx64Build/master/assets/run.bat ${ASEPRITE_TEMP}\run.bat

# Copy our build script.
# COPY assets\build.ps1 ${ASEPRITE_TOOLS}\
ADD https://raw.githubusercontent.com/notisrac/AsepriteWindowsx64Build/master/assets/build.ps1 ${ASEPRITE_TOOLS}\build.ps1

# create the distribution folder, and make it a mount point
RUN mkdir %ASEPRITE_DIST%
VOLUME ${ASEPRITE_DIST}

# Define the entry point for the docker container.
# This entry point starts the developer command prompt and launches the PowerShell shell.
ENTRYPOINT ["C:\\BuildTools\\Common7\\Tools\\VsDevCmd.bat", "-arch=x64", "&&", "%ASEPRITE_TEMP%\\run.bat"]