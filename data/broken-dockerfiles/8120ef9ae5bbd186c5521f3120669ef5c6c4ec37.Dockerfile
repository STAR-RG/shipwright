FROM base/devel:latest

# fetch dependencies
RUN pacman --noconfirm -Syu bower cairo giflib graphicsmagick grunt-cli libjpeg-turbo npm

# more dependencies
WORKDIR /unitdb
ENTRYPOINT npm install && bower install --allow-root && grunt serve

