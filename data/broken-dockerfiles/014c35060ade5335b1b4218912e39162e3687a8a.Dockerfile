FROM microsoft/dotnet:2.2-sdk AS build-env
WORKDIR /app

COPY . ./

# Build app
RUN dotnet build

ENTRYPOINT bash