# -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# IMAGE BUILD
# -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# base image
# myrtille works with all versions of Windows (desktop and server), starting from Windows 7 and Windows Server 2008; choose the base image you want to use (size may vary)
# the myrtille installer will anyway install the roles and features required by myrtille (see Install.ps1), if they are not already installed on the base image
FROM mcr.microsoft.com/windows/servercore:ltsc2019
#FROM mcr.microsoft.com/dotnet/framework/aspnet:4.8
#FROM mcr.microsoft.com/windows:1909

# copy the installer into the container
ADD myrtille.msi /myrtille.msi

# run the installer within the container
# passing params to msiexec to override the default settings of the installer doesn't work; the custom actions just ignore them
# TODO: dig this issue, maybe use orca to change that unwanted behavior?
#RUN msiexec /i myrtille.msi /quiet PDFPRINTER=""
RUN msiexec /i myrtille.msi /quiet
  
# open http and https ports on the container
EXPOSE 80
EXPOSE 443

# entry point
SHELL ["powershell"]
RUN Invoke-WebRequest -UseBasicParsing -Uri 'https://dotnetbinaries.blob.core.windows.net/servicemonitor/2.0.1.6/ServiceMonitor.exe' -OutFile 'C:\ServiceMonitor.exe'
ENTRYPOINT ["C:\\ServiceMonitor.exe", "w3svc"]

# -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# NOTES AND LIMITATIONS
# -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# Docker must be configured to use Windows containers, with Hyper-V isolation (see https://docs.microsoft.com/en-us/virtualization/windowscontainers/manage-containers/hyperv-container)
# if you want to run Docker within a VM, you will need to enable nested virtualization with Hyper-V (see https://docs.microsoft.com/en-us/virtualization/hyper-v-on-windows/user-guide/nested-virtualization)
# the host can be Windows 10 Pro or Windows Server 2016 or greater

# printer and audio redirection through RDP is not supported by Windows containers at the moment
# the myrtille installer used by this Dockerfile must be built with the PDF printer option unchecked

# -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# DATA PERSISTENCE
# -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# the myrtille image will use the default settings, empty database and logs
# every new container based on it will have the same default settings, empty database and logs

# if you intend to have custom settings, manage your hosts or keep track of the logs, you can (non-exhaustively):
# - create a Dockerfile with myrtille as a base image and copy your modified files over the original ones (replacing them)
# - commit a modified container into a new image (i.e.: "myrtille_custom") that will be your new image reference

# the 1st method is preferred because it will help you to keep track of your changes
# this will be helpful when you want to use a newer myrtille version (using a different tag) and report these changes
# for example, you could set the myrtille admin password (bin\myrtille.services.exe.config, "LocalAdminPassword") once for all
# regarding the hosts management, you could use an external database (bin\myrtille.services.exe.config, "enterpriseDBConnection"), so that every container will share the same data
# build your Dockerfile with a different image name (i.e.: "myrtille_custom")

# -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# USEFUL COMMANDS
# -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# IMPORTANT! if you have a ~ 15 secs delay on each Docker command under Windows, disable NETBIOS over TCP/IP on each of your network adapters (TCP/IP v4 Properties)
# see https://github.com/docker/for-win/issues/2131#issuecomment-505286617

# to list the network adapters available to Docker:
# docker network ls

# to build the myrtille image (using Docker Desktop or Toolbox), have this Dockerfile and the myrtille installer (.msi file) into a folder, move into this folder then run this command:
# you also need to provide a network adapter able to download the service monitor during the build. Optionally, you can add a version tag to the image (useful to manage different versions of myrtille)
# docker build --network="<network adapter>" -t myrtille(:tag) .

# to run an image (in detached mode) and provide the resulting container a network adapter able to connect your hosts:
# docker run -d --network="<network adapter>" <image name>(:tag)

# to list the containers:
# docker ps -a

# to open a shell into a container (and be able to explore it, check its ip address, logs, etc.):
# docker exec -it <container ID> cmd
# docker exec -it <container ID> powershell

# to stop a container:
# docker stop <container ID>

# to commit a container into a new image (and be able to persist its config, data and logs):
# docker commit <container ID> <image name>(:tag)

# -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# DISK CLEANUP
# -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# after a while, you might want to clean the unused containers and images to free some space

# remove all containers (powershell):
# docker rm $ (docker ps -a -q)

# remove all dangling images:
# docker image prune

# more help: https://docs.docker.com/