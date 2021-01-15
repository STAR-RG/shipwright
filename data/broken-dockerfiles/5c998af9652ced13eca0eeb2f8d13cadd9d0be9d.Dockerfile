# Dockerfile for running NuGEN's Fusion Workflow

FROM ubuntu:14.04
MAINTAINER Anand Patel

RUN echo "1.0" > /version

ENV PATH /opt/miniconda/bin:$PATH

# Get basic ubuntu packages needed
RUN apt-get update && apt-get install -y -qq \
	wget build-essential git zip unzip tar libncurses-dev

# Set up Miniconda environment for python2
RUN cd /opt;\
	wget https://repo.continuum.io/miniconda/Miniconda-latest-Linux-x86_64.sh -O miniconda.sh;\
	chmod +x miniconda.sh;\
	./miniconda.sh -p /opt/miniconda -b;\
	conda update --yes conda\

	conda install --yes python=2.7;\
#	conda install --yes numpy; \
#	conda install --yes pandas=0.15.2; \
#	conda install --yes matplotlib

RUN cd /opt;\
	wget http://zlib.net/zlib-1.2.8.tar.gz;\
	tar xzvf zlib-1.2.8.tar.gz;\
	cd zlib-1.2.8;\
	make distclean;\
	./configure;\
	make;\
	make install;\
	rm ../zlib-1.2.8.tar.gz

# Installs samtools 1.3
#RUN cd /opt;\
#	wget https://github.com/samtools/samtools/releases/download/1.3/samtools-1.3.tar.bz2;\
#	tar xjvf samtools-1.3.tar.bz2;\
#	cd samtools-1.3;\
#	./configure --enable-plugins --without-curses --prefix /usr;\
#	make all all-htslib;\
#	make install install-htslib;\
#	rm ../samtools-1.3.tar.bz2


# Installs samtools 1.2
#RUN cd /opt;\
#	wget https://github.com/samtools/samtools/releases/download/1.2/samtools-1.2.tar.bz2;\
#	tar xjvf samtools-1.2.tar.bz2;\
#	cd samtools-1.2;\
#	./configure --enable-plugins --without-curses --prefix /usr;\
#	make all all-htslib;\
#	make install install-htslib;\
#	rm ../samtools-1.2.tar.bz2

# Installs samtools 0.1.19
RUN cd /opt;\
	wget https://github.com/samtools/samtools/archive/0.1.19.tar.gz;\
	tar xzvf 0.1.19.tar.gz;\
	cd samtools-0.1.19;\
	make;\
	cp samtools /usr/bin;\
	rm ../0.1.19.tar.gz



RUN pip install --upgrade pip

#ADD ./cprog/fastq-multx /usr/local/bin/fastq-multx
ADD . /opt/nudup/

#ADD ./docker-entrypoint.sh /docker-entrypoint.sh
#ENTRYPOINT ["/docker-entrypoint.sh"]



