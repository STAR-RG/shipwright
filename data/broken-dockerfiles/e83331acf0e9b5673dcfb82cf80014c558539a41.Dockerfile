FROM debian:jessie

RUN apt-get update && apt-get upgrade -y && apt-get install -y --no-install-recommends \
	curl \
	automake \
	gcc \
	g++ \
	make \
	libtool \
	ca-certificates \
#	python3-pip \
#	python3-dev \
	python-pip \
	python-dev \
	bzip2

# Upgrade pip
# RUN pip3 install --upgrade --ignore-installed pip
RUN pip install --upgrade --ignore-installed pip

# Install Gumbo
ENV GUMBO_VERSION 0.10.1
RUN curl -sL https://github.com/google/gumbo-parser/archive/v$GUMBO_VERSION.tar.gz > gumbo.tgz && \
	rm -rf gumbo-parser-$GUMBO_VERSION gumbo-parser && \
	tar zxf gumbo.tgz && \
	mv gumbo-parser-$GUMBO_VERSION gumbo-parser && \
	cd gumbo-parser && ./autogen.sh && ./configure && make && \
	make install && ldconfig && cd .. && \
	rm -rf gumbo.tgz gumbo-parser


# Optional dependencies for benchmarking
RUN apt-get install -y --no-install-recommends \
	libxml2-dev \
	libxslt1-dev \
	zlib1g-dev

# RUN ln -s /usr/local/lib/libgumbo.so /usr/lib/python2.7/dist-packages/gumbo/libgumbo.so

# Install PyPy
RUN curl -L 'https://bitbucket.org/squeaky/portable-pypy/downloads/pypy-5.3.1-linux_x86_64-portable.tar.bz2' -o /pypy.tar.bz2 && \
  mkdir -p /opt/pypy/ && tar jxvf /pypy.tar.bz2 -C /opt/pypy/  --strip-components=1 && \
  rm /pypy.tar.bz2

RUN /opt/pypy/bin/pypy -m ensurepip
RUN /opt/pypy/bin/pip install --upgrade --ignore-installed pip

# Install RE2
RUN mkdir -p /tmp/re2 && \
	curl -L 'https://github.com/google/re2/archive/636bc71728b7488c43f9441ecfc80bdb1905b3f0.tar.gz' -o /tmp/re2/re2.tar.gz && \
	cd /tmp/re2 && tar zxvf re2.tar.gz --strip-components=1 && \
	make && make install && \
	rm -rf /tmp/re2 && \
	ldconfig

# Install Python dependencies

ADD requirements-benchmark.txt /requirements-benchmark.txt
ADD requirements.txt /requirements.txt
# RUN pip3 install -r requirements.txt
# RUN pip3 install -r requirements-benchmark.txt
RUN pip install -r requirements.txt
RUN pip install -r requirements-benchmark.txt
RUN /opt/pypy/bin/pip install -r /requirements.txt
RUN /opt/pypy/bin/pip install setuptools==18.5  # Because of html5lib
RUN /opt/pypy/bin/pip install -r /requirements-benchmark.txt

RUN mkdir -p /cosr/gumbocy
