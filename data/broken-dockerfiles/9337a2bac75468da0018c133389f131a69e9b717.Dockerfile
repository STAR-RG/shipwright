# escape=` (backtick)
# The above line changes the escape character to the backtick char so that Windows paths don't get mangled.

FROM microsoft/dotnet-framework:4.6.2

# Copy the SDK to the docker image.
COPY .\Photon-OnPremise-Server-SDK_v*\deploy C:\PhotonServer\deploy

# Change the working directory so that the SDK launches correctly.
WORKDIR C:\PhotonServer\deploy\bin_Win32\

# default ports exposed by LoadBalancing server.
EXPOSE 5055 5056 4530 4531 4520 843 943 9090 9091

# run the photon server application.
ENTRYPOINT ["_run-Photon-as-application.start.cmd"]
