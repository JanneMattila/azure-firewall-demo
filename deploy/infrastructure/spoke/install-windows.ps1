# Installation script for Windows
$ProgressPreference = "SilentlyContinue"

# If C:\inetpub\wwwroot\ is not empty, then return
if (Test-Path C:\inetpub\wwwroot\) {
    Write-Host "WebApp Network Tester already installed."
    exit
}

# Install IIS
Install-WindowsFeature -name Web-Server -IncludeManagementTools

New-Item \temp\ -ItemType Directory -Force
Set-Location \temp\

# The .NET Core Hosting Bundle
# https://learn.microsoft.com/en-us/aspnet/core/host-and-deploy/iis/hosting-bundle?view=aspnetcore-9.0
# https://dotnet.microsoft.com/permalink/dotnetcore-current-windows-runtime-bundle-installer
Invoke-WebRequest "https://builds.dotnet.microsoft.com/dotnet/aspnetcore/Runtime/9.0.2/dotnet-hosting-9.0.2-win.exe" -OutFile dotnet-hosting.exe
.\dotnet-hosting.exe /quiet

Invoke-WebRequest "https://github.com/JanneMattila/webapp-network-tester/releases/latest/download/webappnetworktester.zip" -OutFile webapp-network-tester.zip
Expand-Archive webapp-network-tester.zip

# Copy the webapp-network-tester to the IIS
Remove-Item C:\inetpub\wwwroot\* -Recurse -Force
Copy-Item -Path webapp-network-tester\artifacts\webappnetworktester\* -Destination C:\inetpub\wwwroot\ -Recurse -Force

# Force the IIS to restart
net stop was /y
net start w3svc
