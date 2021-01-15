# Use a minimal Alpine Linux image
FROM mhart/alpine-node:6

# Jobs used in make command
ARG JOBS=4

# Starts our installs
WORKDIR /app
COPY . .

# Install a fresh ffmpeg ourselves as the one on Alpine Linux repo is old
# Taken from https://github.com/opencoconut/ffmpeg/ for minimal Alpine build
# Sometimes npm fails to run the install hook, to enable the use of optimized
# native code, we need running that manually
WORKDIR /tmp/ffmpeg
ENV FFMPEG_VERSION=3.3.3
RUN apk add --update build-base openssh-client python git curl nasm tar bzip2 libsodium-dev \
	zlib-dev openssl-dev yasm-dev lame-dev libogg-dev x264-dev libvpx-dev libvorbis-dev x265-dev freetype-dev libass-dev libwebp-dev rtmpdump-dev libtheora-dev opus-dev && \

	DIR=$(mktemp -d) && cd ${DIR} && \

	curl -s http://ffmpeg.org/releases/ffmpeg-${FFMPEG_VERSION}.tar.gz | tar zxvf - -C . && \
	cd ffmpeg-${FFMPEG_VERSION} && \
	./configure \
	--enable-version3 --enable-gpl --enable-nonfree --enable-small --enable-libmp3lame --enable-libx264 --enable-libx265 --enable-libvpx --enable-libtheora --enable-libvorbis --enable-libopus --enable-libass --enable-libwebp --enable-librtmp --enable-postproc --enable-avresample --enable-libfreetype --enable-openssl --disable-debug && \
	make -j $JOBS && \
	make install && \
	make distclean && \
	rm -rf ${DIR} && \

	cd /app && \
	npm install --production --force && \
	npm cache clean --force && \
	npm run install && \
    
	apk del build-base curl tar bzip2 x264 openssh-client openssl nasm python git && \
	rm -rf /var/cache/apk/* && \
	rm -rf /tmp/*

# Expose ports
EXPOSE 8080
EXPOSE 5000

# Specify endpoint
WORKDIR /app
CMD ["node", "index.js"]
