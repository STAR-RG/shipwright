FROM nginx

RUN apt-get update && apt-get install -y npm git && apt-get clean
RUN ln -s /usr/bin/nodejs /usr/bin/node
RUN npm install -g bower

COPY bower.json /tmp
RUN cd /tmp && bower install --allow-root

COPY . /usr/share/nginx/html
RUN cp -R /tmp/bower_components /usr/share/nginx/html

EXPOSE 80
