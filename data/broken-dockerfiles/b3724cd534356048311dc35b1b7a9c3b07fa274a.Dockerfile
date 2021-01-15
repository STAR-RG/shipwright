FROM ubuntu:artful

RUN apt-get update \
	&& apt-get install -y \
		wget \
		unzip \
		fontconfig \
		locales \
		gconf-service \
		libasound2 \
		libatk1.0-0 \
		libc6 \
		libcairo2 \
		libcups2 \
		libdbus-1-3 \
		libexpat1 \
		libfontconfig1 \
		libgcc1 \
		libgconf-2-4 \
		libgdk-pixbuf2.0-0 \
		libglib2.0-0 \
		libgtk-3-0 \
		libnspr4 \
		libpango-1.0-0 \
		libpangocairo-1.0-0 \
		libstdc++6 \
		libx11-6 \
		libx11-xcb1 \
		libxcb1 \
		libxcomposite1 \
		libxcursor1 \
		libxdamage1 \
		libxext6 \
		libxfixes3 \
		libxi6 \
		libxrandr2 \
		libxrender1 \
		libxss1 \
		libxtst6 \
		ca-certificates \
		fonts-liberation \
		libappindicator1 \
		libnss3 \
		lsb-release \
		xdg-utils \
		xvfb \
		libvips42 \
		awscli \
		curl \
    && curl -sL https://deb.nodesource.com/setup_8.x | bash - \
	&& apt-get update \
    && apt-get install -y nodejs

ENV YARN_VERSION 1.3.2

RUN curl -fSLO --compressed "https://yarnpkg.com/downloads/$YARN_VERSION/yarn-v$YARN_VERSION.tar.gz" \
  && mkdir -p /opt/yarn \
  && tar -xzf yarn-v$YARN_VERSION.tar.gz -C /opt/yarn --strip-components=1 \
  && ln -s /opt/yarn/bin/yarn /usr/local/bin/yarn \
  && ln -s /opt/yarn/bin/yarn /usr/local/bin/yarnpkg \
  && rm yarn-v$YARN_VERSION.tar.gz \
  && apt-get clean

ADD cocos-build.sh /opt/cocos-build.sh
ADD cocos-creator /opt/cocos-creator 

ENTRYPOINT ["/opt/cocos-build.sh"]