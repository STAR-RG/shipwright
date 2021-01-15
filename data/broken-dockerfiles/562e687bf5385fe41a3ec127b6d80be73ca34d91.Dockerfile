FROM nginx


env NODEREPO node_7.x
env DISTRO jessie
RUN apt-get update && apt-get install -y curl apt-transport-https git-core
RUN curl -v https://deb.nodesource.com/gpgkey/nodesource.gpg.key | apt-key add -
RUN echo deb https://deb.nodesource.com/${NODEREPO} ${DISTRO} main > /etc/apt/sources.list.d/nodesource.list
RUN echo deb-src https://deb.nodesource.com/${NODEREPO} ${DISTRO} main >> /etc/apt/sources.list.d/nodesource.list
RUN apt-get update && apt-get install -y nodejs build-essential

COPY ./herald /tmp/herald
RUN cd /tmp/herald && npm install && npm run-script build -- -prod && rm -rf node_modules
RUN cd /tmp/herald/dist/ && cp -avr * /usr/share/nginx/html/.

COPY ./nginx/conf.d /etc/nginx/conf.d

EXPOSE 80
