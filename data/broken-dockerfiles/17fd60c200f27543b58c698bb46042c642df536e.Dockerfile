FROM microsoft/dotnet:2.1-sdk as build-env

WORKDIR /src

COPY . .

RUN dotnet restore src/Blog.Core.sln

RUN dotnet publish src/Blog.Core.sln --output /output --configuration Release

FROM microsoft/dotnet:2.1-aspnetcore-runtime
WORKDIR /app

COPY --from=build-env /output . 
EXPOSE 5000
ENTRYPOINT [ "dotnet", "blog.core.dll" ]

