FROM mcr.microsoft.com/dotnet/core/sdk:2.2 AS build-env
WORKDIR /app
RUN mkdir output

COPY ./ ./
RUN dotnet restore
RUN dotnet publish src/Catalyst.Node.POA.CE/Catalyst.Node.POA.CE.csproj -c Debug -o output

# Build runtime image
FROM mcr.microsoft.com/dotnet/core/sdk:2.2
RUN apt update -y; apt-get install dnsutils lsof -y
WORKDIR /app
COPY --from=build-env /app/output .
CMD ["dotnet", "Catalyst.Dfs.SeedNode.dll", "--ipfs-password", "test"]
