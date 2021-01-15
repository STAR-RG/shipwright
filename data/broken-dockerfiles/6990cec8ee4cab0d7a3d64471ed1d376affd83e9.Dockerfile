FROM microsoft/aspnet

# setup IIS
ADD iisconfig.ps1 ./iisconfig.ps1
RUN powershell.exe c:\iisconfig.ps1

# deploy the app
COPY . /app

# configure the new site in
RUN powershell -NoProfile -Command \
    Import-module IISAdministration; \
    New-IISSite -Name "cms.umbraco.local" -PhysicalPath "C:\app" -BindingInformation "*:8080:" 

# This instruction tells the container to listen on port 8080. 
EXPOSE 8080
