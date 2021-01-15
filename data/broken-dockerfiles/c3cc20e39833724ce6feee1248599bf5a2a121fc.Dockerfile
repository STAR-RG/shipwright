FROM adreeve/python-numpy:latest 

ENV PATH /usr/local/bin:$PATH

RUN mkdir -p /home/progs
WORKDIR /home/progs

RUN apt-get update \
    && apt-get --yes install git ssh rsync nano graphviz \
    wget zlibc zlib1g-dev unzip zip \
    libncurses5-dev libncursesw5-dev libboost-dev \
    python3-pip 

RUN pip3 install snakemake pyyaml psutil numexpr --upgrade

#    python-software-properties\
#    build-essential \
#    python3-software-properties \
#    software-properties-common \
#    libncurses5-dev libncursesw5-dev libboost-dev

## SnakeChunks

RUN wget https://github.com/snakechunks/snakechunks/archive/4.0.tar.gz && \
    tar zvxf 4.0.tar.gz && \
    ln -s SnakeChunks-4.0 SnakeChunks && \
    rm 4.0.tar.gz

## Programs

# bowtie2
RUN wget --no-clobber http://downloads.sourceforge.net/project/bowtie-bio/bowtie2/2.2.6/bowtie2-2.2.6-linux-x86_64.zip && \
	unzip bowtie2-2.2.6-linux-x86_64.zip && \
	cp `find bowtie2-2.2.6/ -maxdepth 1 -executable -type f` /usr/local/bin

# fastqc
RUN wget --no-clobber http://www.bioinformatics.babraham.ac.uk/projects/fastqc/fastqc_v0.11.5.zip && \
	unzip -o fastqc_v0.11.5.zip && \
	chmod +x FastQC/fastqc && \
	cp FastQC/fastqc /usr/local/bin

# samtools
RUN wget --no-clobber http://sourceforge.net/projects/samtools/files/samtools/1.3/samtools-1.3.tar.bz2 && \
	bunzip2 -f samtools-1.3.tar.bz2 && \
	tar xvf samtools-1.3.tar && \
	cd samtools-1.3 && \
	make  && \
	sudo make install

WORKDIR /home/progs

# bedtools
RUN wget --no-clobber https://github.com/arq5x/bedtools2/releases/download/v2.24.0/bedtools-2.24.0.tar.gz && \
	tar xvfz bedtools-2.24.0.tar.gz && \
	cd bedtools2 && \
	make && \
	sudo make install

WORKDIR /home/progs

# macs2
RUN sudo pip install MACS2

# homer
RUN mkdir Homer && \
	cd Homer && \
	wget -nc "http://homer.salk.edu/homer/configureHomer.pl" && \
	perl configureHomer.pl -install homer && \
	cp `find bin/ -maxdepth 1 -executable -type f` /usr/local/bin

RUN pip3 install -U pandas

MAINTAINER Claire Rioualen <claire.rioualen@inserm.fr> 




