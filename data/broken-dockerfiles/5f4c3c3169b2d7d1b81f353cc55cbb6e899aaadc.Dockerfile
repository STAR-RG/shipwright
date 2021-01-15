# docker部署
# 1. docker build --build-arg EGG_SERVER_ENV=prod -t app .
# 2. docker run -d -e EGG_SERVER_ENV=prod --name app -p 7001:7001 app:latest

# 安装node环境 https://github.com/mhart/alpine-node
FROM mhart/alpine-node:8.9

# 创建app目录
RUN mkdir -p /usr/local/project/
COPY . /usr/local/project/
WORKDIR /usr/local/project/

# 安装依赖
RUN npm i --registry=https://registry.npm.taobao.org

# 编译
ARG EGG_SERVER_ENV
ENV EGG_SERVER_ENV=${EGG_SERVER_ENV:-prod}
RUN npm run build

# 运行
EXPOSE 7001
CMD npm run start
