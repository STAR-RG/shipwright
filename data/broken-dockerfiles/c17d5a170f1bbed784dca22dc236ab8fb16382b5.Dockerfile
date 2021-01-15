FROM python:3.5-slim
MAINTAINER Will Wolf <williamabrwolf@gmail.com>

WORKDIR /root

RUN apt-get update && apt-get install -y build-essential python3-dev libpq-dev

COPY requirements.txt /root/
RUN pip install -r requirements.txt

COPY package.json /root/

RUN \
  apt-get install -y curl python-software-properties && \
  curl -sL https://deb.nodesource.com/setup_6.x | bash - && \
  apt-get install nodejs && \
  npm install

COPY . /root/

RUN npm run build
