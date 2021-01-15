FROM ubuntu:16.04
MAINTAINER Zebula Sampedro

# Installs
RUN apt-get update && apt-get install -y build-essential \
    python-dev python-pip \
    nodejs nodejs-legacy npm
RUN npm install -g npm@2

# Add user
RUN useradd -m sandstone
RUN echo "sandstone:sandstone" | chpasswd

# Setup settings overrides
RUN mkdir -p /home/sandstone/.config/sandstone
RUN echo "INSTALLED_APPS=('sandstone.lib','sandstone.apps.codeeditor',\
  'sandstone.apps.filebrowser','sandstone.apps.webterminal',)" > \
  /home/sandstone/.config/sandstone/sandstone_settings.py
RUN chown -R sandstone:sandstone /home/sandstone/.config/

# Install Sandstone IDE
RUN mkdir -p /opt/sandstone-ide/sandstone
ADD sandstone /opt/sandstone-ide/sandstone/
ADD ["DESCRIPTION.rst","MANIFEST.in","requirements.txt","setup.py", "/opt/sandstone-ide/"]
RUN cd /opt/sandstone-ide/sandstone/client && npm install
RUN cd /opt/sandstone-ide && python /opt/sandstone-ide/setup.py install

ENV "SANDSTONE_SETTINGS=/home/sandstone/.config/sandstone/sandstone_settings.py"
CMD ["/usr/local/bin/sandstone"]
