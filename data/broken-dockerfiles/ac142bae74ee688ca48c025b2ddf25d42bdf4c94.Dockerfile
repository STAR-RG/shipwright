FROM jekyll/jekyll:latest
MAINTAINER Zach Latta <zach@hackclub.io>

RUN rm -rf /srv/jekyll/
COPY . /srv/jekyll/
RUN chown -R jekyll:jekyll /srv/jekyll/

EXPOSE 8080
CMD ["jekyll", "serve", "-P", "8080", "-H", "0.0.0.0"]
