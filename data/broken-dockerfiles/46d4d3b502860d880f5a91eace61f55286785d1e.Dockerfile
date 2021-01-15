FROM ubuntu:14.04.2

MAINTAINER joee liew liewjoee@yahoo.com

#Add display driver
#ADD NVIDIA-Linux-x86_64-340.76.run /tmp/NVIDIA-DRIVER.run
RUN apt-get update && apt-get install -yq kmod mesa-utils software-properties-common

#ADD codelite
RUN apt-key adv --fetch-keys http://repos.codelite.org/CodeLite.asc
RUN apt-add-repository 'deb http://repos.codelite.org/ubuntu/ trusty universe'

#ADD mesa driver
RUN apt-add-repository ppa:oibaf/graphics-drivers

#ADD open source nvidia driver
RUN add-apt-repository ppa:xorg-edgers/ppa

RUN apt-get update

RUN apt-get install -yq build-essential mono-gmcs mono-xbuild mono-dmcs \
  libmono-corlib4.0-cil libmono-system-data-datasetextensions4.0-cil \
  libmono-system-web-extensions4.0-cil libmono-system-management4.0-cil \
  libmono-system-xml-linq4.0-cil cmake dos2unix clang-3.5 libfreetype6-dev \
  libgtk-3-dev libmono-microsoft-build-tasks-v4.0-4.0-cil \
  xdg-user-dirs pulseaudio alsa-utils \
  x11-apps libclang-common-3.5-dev libclang1-3.5 libllvm3.5 llvm-3.5 \
  llvm-3.5-dev llvm-3.5-runtime libgtk-3-0 git codelite wxcrafter

#Dont install all the recommended, will blow up the package
RUN apt-get install -yq --no-install-recommends nvidia-340

#why the libdbus gone screwy
RUN apt-get -yq install libdbus-1-3 libdbus-1-dev
#had manually soft link the library
RUN ln -s /lib/x86_64-linux-gnu/libdbus-1.so.3.7.6 /lib/x86_64-linux-gnu/libdbus-1.so

#thin up the whole images
RUN apt-get autoremove
RUN apt-get autoclean

Add UnrealEngine /UnrealEngine

#Add user `unreal`
RUN useradd -ms /bin/bash unreal
RUN adduser unreal sudo
#RUN ./Setup.sh --> this is run on the host to safe time on the docker build and rebuild in case you need to add dependecies
WORKDIR /UnrealEngine
RUN ./GenerateProjectFiles.sh

#change the directory to the unreal user
RUN chown -R unreal:unreal /UnrealEngine
