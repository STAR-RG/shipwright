FROM node:8.9.1-alpine

RUN mkdir -p /opt/app

COPY . /opt/app

WORKDIR /opt/app

RUN apk add --no-cache --virtual build-deps \
			python=2.7.13-r1 \
			make=4.2.1-r0 \
			g++=6.3.0-r4 \
	&& npm rebuild \
	&& apk del build-deps

CMD ["npm", "start"]
