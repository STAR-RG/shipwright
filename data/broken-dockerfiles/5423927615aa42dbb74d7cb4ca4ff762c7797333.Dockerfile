FROM node:8
MAINTAINER Ciao Chung

RUN apt-get update -y
RUN apt-get install -y fonts-liberation libappindicator3-1 libasound2 libatk-bridge2.0-0 && \
  libatspi2.0-0 libgtk-3-0 libnspr4 libnss3 libx11-xcb1 && \
  libxss1 libxtst6 lsb-release xdg-utils; exit 0
RUN apt --fix-broken install -y
RUN wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
RUN dpkg -i google-chrome*.deb; exit 0
RUN apt-get install -f -y
RUN rm -f google-chrome*.deb
RUN google-chrome --version
RUN yarn global add ciao-ssr pm2

EXPOSE 3000

CMD ["sh", "-c", "pm2 start ciao-ssr --name='ssr' -- --config=/config/ssr.json && tail -f /dev/null"]