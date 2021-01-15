# Start with Ubuntu base image
FROM user1m/pix2pix
# FROM ubuntu:14.04
MAINTAINER Claudius Mbemba <clmb@microsoft.com>

# Run image updates
RUN sudo apt-get update
# Install Node & NPM
RUN sudo apt-get install -y curl; curl -sL "https://deb.nodesource.com/setup_8.x" | sudo bash -; sudo apt-get install -y nodejs;
#sudo mv -f /usr/bin/nodejs /usr/bin/node

# Install pix2pix Py Deps
#sudo pip install -r requirements.txt --no-index
RUN sudo apt-get update; sudo apt-get install -y python python-dev
# build-essential libtool libsm-dev libglpk-dev libglib2.0-0
# RUN sudo apt-get install -y wget;
RUN wget https://bootstrap.pypa.io/get-pip.py; python get-pip.py; cp /usr/local/bin/pip /usr/bin; pip -V; pip install requests[security]
RUN sudo pip install opencv-python; pip install http://download.pytorch.org/whl/cu80/torch-0.2.0.post3-cp27-cp27mu-manylinux1_x86_64.whl; pip install torchvision dominate

# Install deps for Sketch tf-model
RUN sudo apt-get install -y python-tk; pip install matplotlib pandas h5py tqdm sklearn keras tensorflow

# SSH
RUN apt-get update \
    && apt-get install -y --no-install-recommends openssh-server \
    && echo "root:Docker!" | chpasswd

#Copy the sshd_config file to its new location
COPY sketch2pix/sshd_config /etc/ssh/

# Configure ports
EXPOSE 2222 80 8080 443

# Start the SSH service
RUN service ssh start

# Set ENV Var
ENV PORT 80

# Set ~/home as working directory
WORKDIR /workdir/

# Copy Project & API
COPY ./dataset/PencilSketch /workdir/model/dataset/PencilSketch/
COPY ./Sketch/ /workdir/model/Sketch/
COPY ./scripts/ /scripts
COPY ./sketchme-api /workdir/app/

# Setup node
# RUN cd /workdir/app/; mkdir uploads savedImages; npm i
ENTRYPOINT /scripts/init.sh

# # Start API
# CMD cd /workdir/app/; npm start &; bash

