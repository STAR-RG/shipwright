FROM python:3.6.4-stretch

RUN apt-get update
RUN apt-get install -y libgl1-mesa-glx libnss3 libxtst6 libxext6 \
	libasound2 libegl1-mesa libpulse-mainloop-glib0 libpulse0 \
	pyqt5-dev-tools qtchooser

WORKDIR /usr/local

# Install dependencies.
ADD requirements.txt /usr/local
RUN cd /usr/local && \
    pip3 install -r requirements.txt

# Get ipfs binary
RUN wget http://dist.ipfs.io/go-ipfs/v0.4.17/go-ipfs_v0.4.17_linux-amd64.tar.gz
RUN tar -xvf go-ipfs_v0.4.17_linux-amd64.tar.gz
RUN cp go-ipfs/ipfs /usr/local/bin

# Add source code.
COPY README.rst COPYING LICENSE LICENSE.go-ipfs /usr/local/galacteek/
COPY requirements.txt setup.py galacteek.pro \
	/usr/local/galacteek/
COPY docs /usr/local/galacteek/docs
COPY share /usr/local/galacteek/share
COPY galacteek/ /usr/local/galacteek/galacteek

RUN cd /usr/local/galacteek && \
	python setup.py build install

ENTRYPOINT ["galacteek"]
