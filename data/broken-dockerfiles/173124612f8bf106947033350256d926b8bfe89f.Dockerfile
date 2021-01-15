FROM microsoft/dotnet:2.0-sdk

LABEL maintainer="guy.pascarella@gmail.com"

# Inject the Opux source into the image
COPY src/Opux /app

# Set the current working directory
WORKDIR /app

# Build Opux
RUN dotnet restore \
&& dotnet build

# TODO: Make this a multi-stage build that doesn't contain the source

# Note: The run command of dotnet is the more official version of the exec command
#CMD ["dotnet", "run"]
CMD ["dotnet", "exec", "/app/bin/Debug/netcoreapp2.0/Opux.dll"]
