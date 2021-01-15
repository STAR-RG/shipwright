From andmos/mono-pcl:latest

ADD HealthKitServer.Host HealthKitServer.Host
ADD HealthKitServer.Server HealthKitServer.Server
ADD HealthKitServer.Common HealthKitServer.Common

ADD HealthKitServer.sln /

RUN nuget restore HealthKitServer.sln
RUN xbuild /property:Configuration=Release /property:OutDir=/HealthKitServer/build/ HealthKitServer.Host/HealthKitServer.Host.csproj

EXPOSE 5000
CMD mono /HealthKitServer/build/HealthKitServer.Host.exe
