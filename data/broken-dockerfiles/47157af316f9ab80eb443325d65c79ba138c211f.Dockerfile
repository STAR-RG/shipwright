FROM microsoft/iis

# install ASP.NET 4.5
RUN dism /online /enable-feature /all /featurename:IIS-ASPNET45 /NoRestart

# enable windows eventlog
RUN powershell.exe -command Set-ItemProperty HKLM:\SYSTEM\CurrentControlSet\Control\WMI\Autologger\EventLog-Application Start 1

# set IIS log fields
RUN /windows/system32/inetsrv/appcmd.exe set config /section:system.applicationHost/sites /siteDefaults.logFile.logExtFileFlags:"Date, Time, ClientIP, UserName, SiteName, ServerIP, Method, UriStem, UriQuery, HttpStatus, Win32Status, TimeTaken, ServerPort, UserAgent, Referer, HttpSubStatus"  /commit:apphost

# deploy webapp
COPY publish /inetpub/wwwroot/iis-demo
RUN /windows/system32/inetsrv/appcmd.exe add app /site.name:"Default Web Site" /path:"/iis-demo" /physicalPath:"c:\inetpub\wwwroot\iis-demo"

# set entrypoint script
ADD SetHostsAndStartMonitoring.cmd \SetHostsAndStartMonitoring.cmd
ENTRYPOINT ["C:\\SetHostsAndStartMonitoring.cmd"]

# declare volumes
VOLUME ["c:/inetpub/logs/LogFiles"]
	