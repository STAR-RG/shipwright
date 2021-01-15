FROM alpine:3.9 as data
WORKDIR /app
RUN apk --update add unzip
ARG script_url=https://github.com/Kaioru/Server.Scripts/releases/download/1.0.0-pre1/Data.zip
ARG data_url=https://github.com/Kaioru/Server.NX/releases/download/1.0.0-pre1/Data.zip
ADD ${script_url} scripts.zip
ADD ${data_url} data.zip
RUN unzip scripts.zip -d scripts/
RUN unzip data.zip -d data/
RUN rm scripts.zip
RUN rm data.zip

FROM mcr.microsoft.com/dotnet/core/sdk:3.0-alpine as build
WORKDIR /code
COPY . .
ARG type="All"
RUN dotnet publish -c Release -o /app src/Edelstein.Service.${type}

FROM mcr.microsoft.com/dotnet/core/runtime:3.0-alpine as runtime
WORKDIR /app
COPY --from=data /app .
COPY --from=build /app .
ARG type="All"
ENV type $type
ENTRYPOINT dotnet Edelstein.Service.$type.dll