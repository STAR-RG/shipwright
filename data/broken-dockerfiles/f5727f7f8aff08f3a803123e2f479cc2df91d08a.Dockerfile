FROM opensuse:leap

RUN \
  zypper ref && \
  zypper -n -q install nodejs-npm git && \
  git config --global http.sslVerify false && \
  git clone https://github.com/heymind/url2leanote.git /app && \
  cd app && \
  npm install && \
  npm install supervisor -g
# RUN find /app
WORKDIR /app
EXPOSE 8080
CMD supervisor /app/app.js 
