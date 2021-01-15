FROM ubuntu

ADD ./webapp /opt/webapp
WORKDIR /opt/webapp

RUN apt-get update -yq && apt-get upgrade -yq && apt-get install -yq curl git nano vim
RUN curl -sL https://deb.nodesource.com/setup_4.x | bash - && apt-get install -yq nodejs build-essential
RUN npm install npm -g
RUN npm install express -g

ENTRYPOINT ["/bin/bash"]
