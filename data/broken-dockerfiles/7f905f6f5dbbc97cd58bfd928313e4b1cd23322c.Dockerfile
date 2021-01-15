FROM octohost/nodejs

RUN npm install harp -g

RUN add-apt-repository -y ppa:nginx/stable
RUN apt-get update

RUN apt-get -y install nginx

RUN mkdir /srv/www

ADD default /etc/nginx/sites-available/default
ADD nginx.conf /etc/nginx/nginx.conf
