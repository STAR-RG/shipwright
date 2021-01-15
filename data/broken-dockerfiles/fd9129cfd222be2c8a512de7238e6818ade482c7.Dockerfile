FROM phusion/baseimage:0.11
RUN useradd -ms /bin/bash newuser

# CMD ["/sbin/my_init"]

RUN mkdir -p /app
WORKDIR /app
COPY . /app

RUN chown -R newuser:newuser /app/codeCellScripts
RUN mkdir /home/newuser/bin
RUN echo "export PATH=/home/newuser/bin" > /home/newuser/.bash_profile
RUN chown root. /home/newuser/.bash_profile
RUN chmod 755 /home/newuser/.bash_profile

RUN chown root. /home/newuser/.bashrc
RUN chmod 755 /home/newuser/.bashrc

RUN install_clean \
  make \
  g++ \
  ruby \
  npm \
  python \
  && npm install \
  && cd client \
  && npm install \
  && npm run build

EXPOSE 8000

USER newuser

CMD ["node", "server.js"]

