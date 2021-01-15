FROM mcr.microsoft.com/dotnet/core/sdk:2.2 AS build-env
WORKDIR /app

# Copy csproj and restore as distinct layers
COPY VkInstruments.ConsoleApp/*.csproj ./VkInstruments.ConsoleApp/
COPY VkInstruments.Core/*.csproj ./VkInstruments.Core/
COPY VkInstruments.Web/*.csproj ./VkInstruments.Web/

RUN dotnet restore VkInstruments.ConsoleApp/
RUN dotnet restore VkInstruments.Core/
RUN dotnet restore VkInstruments.Web/

# Copy everything else and build
COPY . ./
RUN dotnet publish VkInstruments.Web/ -c Release -o /build/VkInstruments.Web/

# Build runtime image
FROM mcr.microsoft.com/dotnet/core/aspnet:2.2
COPY --from=build-env /build/VkInstruments.Web /app/VkInstruments.Web/
WORKDIR /app/VkInstruments.Web
ENTRYPOINT ["dotnet", "VkInstruments.Web.dll"]