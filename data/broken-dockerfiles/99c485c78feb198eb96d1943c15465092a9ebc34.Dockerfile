FROM gliderlabs/alpine:3.2
RUN apk --update add python curl py-pip bash openssh-client git \
  && pip install --upgrade mkdocs \
  && git config --global user.email "team@gliderlabs.com" \
  && git config --global user.name "Gliderbot" \
  && ln -s /root /home/ubuntu \
  && curl -Ls https://github.com/gliderlabs/sigil/releases/download/v0.3.2/sigil_0.3.2_Linux_x86_64.tgz \
    | tar -zxC /bin
ADD ./scripts/* /bin/
ADD ./gh-pages /tmp/gh-pages
ADD ./theme /pagebuilder/theme
WORKDIR /work
EXPOSE 8000
