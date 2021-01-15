FROM node:10-slim
# 创建项目代码的目录
RUN mkdir -p /workspace

# 指定RUN、CMD与ENTRYPOINT命令的工作目录
WORKDIR /workspace

# 复制宿主机当前路径下所有文件到docker的工作目录
COPY . /workspace
# 清除npm缓存文件
RUN npm cache clean --force && npm cache verify
# 如果设置为true，则当运行package scripts时禁止UID/GID互相切换
# RUN npm config set unsafe-perm true

RUN npm config set registry "https://registry.npm.taobao.org"

RUN npm install -g pm2@latest
# Install latest chrome dev package and fonts to support major charsets (Chinese, Japanese, Arabic, Hebrew, Thai and a few others)
# Note: this installs the necessary libs to make the bundled version of Chromium that Puppeteer
# installs, work.
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
  && sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list' \
  && apt-get update \
  && apt-get install -y google-chrome-unstable fonts-ipafont-gothic fonts-wqy-zenhei fonts-thai-tlwg fonts-kacst fonts-freefont-ttf \
  --no-install-recommends \
  && rm -rf /var/lib/apt/lists/*

# 只安装package.json dependencies
RUN npm install --production

RUN npm i puppeteer
# 设置时区
RUN rm -rf /etc/localtime && ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

EXPOSE 8888

CMD [ "pm2-docker", "start", "pm2.json" ]



