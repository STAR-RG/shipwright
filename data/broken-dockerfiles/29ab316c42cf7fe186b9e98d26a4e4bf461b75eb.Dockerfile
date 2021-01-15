FROM node:8-stretch

ARG DEBIAN_FRONTEND=noninteractive
RUN apt -q update && apt install --no-install-recommends -y -q \
    libglu1-mesa \
    libxi6 \
    && rm -rf /var/lib/apt/lists/*

ARG BLENDER279_URL=https://download.blender.org/release/Blender2.79/blender-2.79b-linux-glibc219-x86_64.tar.bz2
RUN mkdir /opt/blender279 && \
	curl -SL "$BLENDER279_URL" | \
	tar -jx -C /opt/blender279 --strip-components=1 && \
    ln -s /opt/blender279/blender /usr/local/bin/blender279b

RUN mkdir /opt/blender280 && \
    BLENDER280_URL="https://builder.blender.org$(curl -s https://builder.blender.org/download/ | \
    grep -oe '[^\"]*blender-2\.80[^\"]*linux[^\"]*-x86_64[^\"]*')"; \
	curl -SL "$BLENDER280_URL" | \
	tar -jx -C /opt/blender280 --strip-components=1 && \
    ln -s /opt/blender280/blender /usr/local/bin/blender28

WORKDIR /tests
COPY tests/package.json /tests/
COPY tests/yarn.lock /tests/
RUN yarn install

COPY tests/*.py /tests/
