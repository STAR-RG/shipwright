# build stage
FROM golang:stretch

# some information about the docker image
LABEL Name="Macaw" Version="0.7" Maintainer="Marcus Renno <me@rennomarcus.com>"

# install dependecies
RUN apt-get -qq update && apt-get install -y \
    alsa-utils \
    libgl1-mesa-dri \
    libsdl2-dev \
    libsdl2-image-dev \
    libsdl2-mixer-dev \
    libsdl2-ttf-dev
RUN go get -d -v github.com/veandco/go-sdl2/sdl && \
    go get -d -v github.com/veandco/go-sdl2/img && \
    go get -d -v github.com/veandco/go-sdl2/mix && \
    go get -d -v github.com/veandco/go-sdl2/ttf && \
    go get -v github.com/tubelz/macaw

# terminal
ENTRYPOINT [ "/bin/bash" ]


