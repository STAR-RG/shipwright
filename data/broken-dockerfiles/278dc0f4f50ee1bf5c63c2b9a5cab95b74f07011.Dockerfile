FROM __ARCH__/__TAG__

COPY bin/qemu-__QEMU__-static /usr/bin/

RUN __DEPENDENCIES__

ENV PKG_CACHE_PATH=/fetched

RUN mkdir -p /fetched && npm install pkg-fetch

RUN /node_modules/.bin/pkg-fetch __NODE_PKG__ __PKG_OS__ __PKG_ARCH__

CMD ["sh"]