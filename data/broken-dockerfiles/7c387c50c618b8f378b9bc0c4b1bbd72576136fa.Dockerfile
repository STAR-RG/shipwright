FROM node:8.6.0-alpine

# Note: Building vips from source because the standard alpine
#       version does not include librsvg which is required for
#       compositing SVGS (text overlay origin)

# Environment Variables
ARG LIBVIPS_VERSION_MAJOR_MINOR=8.5
ARG LIBVIPS_VERSION_PATCH=7

# Install dependencies
RUN echo "http://dl-cdn.alpinelinux.org/alpine/v3.5/community" >> /etc/apk/repositories && \
    apk update && apk upgrade

RUN apk add --no-cache make gcc g++ python git openssh wget autoconf automake build-base ca-certificates

RUN apk add --no-cache \
    zlib libxml2 libxslt glib libexif lcms2 fftw \
    giflib libpng libwebp orc tiff poppler-glib librsvg \
    libtool nasm zlib-dev libxml2-dev libxslt-dev glib-dev \
    libexif-dev lcms2-dev fftw-dev giflib-dev libpng-dev libwebp-dev orc-dev tiff-dev \
    poppler-dev librsvg-dev

# Download libvips
RUN wget -O- https://github.com/libvips/libvips/releases/download/v${LIBVIPS_VERSION_MAJOR_MINOR}.${LIBVIPS_VERSION_PATCH}/vips-${LIBVIPS_VERSION_MAJOR_MINOR}.${LIBVIPS_VERSION_PATCH}.tar.gz | tar xzC /tmp

# Install libvips
RUN cd /tmp/vips-${LIBVIPS_VERSION_MAJOR_MINOR}.${LIBVIPS_VERSION_PATCH} && \
    ./configure --prefix=/usr \
                --without-python \
                --without-gsf \
                --enable-debug=no \
                --disable-dependency-tracking \
                --disable-static \
                --enable-silent-rules && \
    make -s install-strip

# Cleanup
RUN rm -rf /tmp/vips-${LIBVIPS_VERSION_MAJOR_MINOR}.${LIBVIPS_VERSION_PATCH} && \
    rm -rf /var/cache/apk/*

# Install fonts
RUN apk add --no-cache ttf-freefont fontconfig font-noto
RUN fc-cache -fv

# Create application directory
RUN mkdir -p /app
WORKDIR /app

# Install packages
COPY package.json package-lock.json /app/
RUN npm install

# Copy application source code
COPY src /app/

# Expose ports
EXPOSE 80

CMD [ "npm", "start" ]
