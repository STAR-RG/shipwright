
FROM richarvey/nginx-php-fpm:1.4.0
# Comes with alpine linux 3.6

ARG username=nw

WORKDIR ./

COPY . .

ENV DBUSER=nwserver

# Various preps for alpine environment
RUN echo "Commencing PREP..." && \
	apk add make && \
	apk add --upgrade apk-tools && \
	apk update && \
	apk add nodejs && \
	apk add postgresql && \
	echo "Creating the resources file from the resources.build.php..." && \
	#sed "0,/postgres/{s/postgres/${DBUSER}/}" deploy/resources.build.php > deploy/resources.php && \
	#sed "s|/srv/ninjawars/|../..|g" deploy/tests/karma.conf.js > karma.conf.js && \
	echo "PREP done, starting install..." && \
	./configure && make && make install && \
	echo "Install not run."

ENV HOST=0.0.0.0 \
	PORT=7654

EXPOSE 7654

# Run with: docker run --rm -it -p 7654:7654 nw-server
CMD ["make" "test"]