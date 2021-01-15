FROM ubuntu

RUN apt-get update; apt-get install -y curl python3 python3-pip

RUN echo "Install base Debian dependencies..." \
 && apt-get -y update \
 && apt-get -y install apt-transport-https lsb-release vim git curl sudo libpq5 gnupg2 \
 && pip3 install --upgrade pip setuptools wheel virtualenv

RUN echo "Install NodeJS and YARN..." \
 && curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
 && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
 && curl -sL https://deb.nodesource.com/setup_8.x | bash - \
 && apt-get install -y nodejs yarn
