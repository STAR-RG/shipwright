FROM nginx:1.15-alpine
ADD . /tmp
RUN wget https://github.com/gohugoio/hugo/releases/download/v0.45.1/hugo_0.45.1_Linux-64bit.tar.gz \
    && tar -xzvf hugo_0.45.1_Linux-64bit.tar.gz hugo -C /bin && rm hugo_0.45.1_Linux-64bit.tar.gz \
    && rm -rf /usr/share/nginx/html \
    && ln -s /tmp/public/ /usr/share/nginx/html \
    && cd /tmp \
    && hugo \
    && cp ./nginx/default.conf /etc/nginx/conf.d/default.conf
CMD ["/bin/sh", "/tmp/nginx/start.sh"]