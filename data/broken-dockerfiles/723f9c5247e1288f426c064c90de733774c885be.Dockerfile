FROM node:6.9.3
MAINTAINER qiujun i@qiujun.me

RUN npm config set registry https://registry.npm.taobao.org
RUN npm install -q -g pm2 && pm2 dump

COPY . /app
WORKDIR /app
RUN npm install -q

EXPOSE 80 443

CMD ["pm2", "start", "pm2.json", "--no-daemon"]
