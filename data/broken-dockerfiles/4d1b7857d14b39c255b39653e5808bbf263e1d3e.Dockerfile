FROM bioconductor/release_base2
MAINTAINER Mark Dunning<mark.dunning@cruk.cam.ac.uk>

## Install packages from Ubuntu repositories
RUN rm -rf /var/lib/apt/lists/
RUN apt-get update 
RUN apt-get install --fix-missing -y git samtools fastx-toolkit python-dev cmake bwa picard-tools bzip2 tabix bedtools build-essential git-core cmake zlib1g-dev libncurses-dev libbz2-dev liblzma-dev man
 
## Download and install fastqc

WORKDIR /tmp
RUN wget http://www.bioinformatics.babraham.ac.uk/projects/fastqc/fastqc_v0.11.3.zip -P /tmp
RUN unzip fastqc_v0.11.3.zip
RUN sudo chmod 755 FastQC/fastqc
RUN ln -s $(pwd)/FastQC/fastqc /usr/bin/fastqc


## Install cutadapt
RUN wget https://bootstrap.pypa.io/get-pip.py
RUN sudo python get-pip.py
RUN sudo pip install cython
RUN sudo pip install --user --upgrade cutadapt
RUN rm get-pip.py
RUN wget https://github.com/samtools/htslib/releases/download/1.3.1/htslib-1.3.1.tar.bz2
#RUN apt-get install -y bzip2 tabix bedtools build-essential git-core cmake zlib1g-dev libncurses-dev
RUN bzip2 -d htslib-1.3.1.tar.bz2
RUN tar xvf htslib-1.3.1.tar
WORKDIR htslib-1.3.1
RUN make install 
RUN chmod +x ~/.local/bin/cutadapt
RUN ln -s ~/.local/bin/cutadapt /usr/bin/cutadapt


## Install freebayes
#RUN apt-get install -y libbz2-dev liblzma-dev
WORKDIR /tmp
RUN git clone --recursive git://github.com/ekg/freebayes.git
WORKDIR freebayes
RUN make
RUN sudo make install

## Install platypus

WORKDIR /tmp
RUN wget http://www.well.ox.ac.uk/bioinformatics/Software/Platypus-latest.tgz
RUN tar xvf Platypus-latest.tgz
WORKDIR Platypus_0.8.1
RUN ./buildPlatypus.sh
ENV PLATYPUS /tmp/Platypus_0.8.1/Platypus.py

## Install Trimmomatic

WORKDIR /tmp
RUN wget http://www.usadellab.org/cms/uploads/supplementary/Trimmomatic/Trimmomatic-0.36.zip
RUN unzip Trimmomatic-0.36.zip
ENV TRIMMOMATIC /tmp/Trimmomatic-0.36/trimmomatic-0.36.jar

## Install delly

WORKDIR /tmp
RUN wget https://github.com/tobiasrausch/delly/releases/download/v0.7.3/delly_v0.7.3_linux_x86_64bit
RUN ln -s /tmp/delly_v0.7.3_linux_x86_64bit /usr/bin/delly

## Install manta

WORKDIR /tmp
RUN wget https://github.com/Illumina/manta/releases/download/v0.29.6/manta-0.29.6.release_src.tar.bz2
RUN tar -xjf manta-0.29.6.release_src.tar.bz2
RUN mkdir manta-0.29.6.release_src/build/
WORKDIR manta-0.29.6.release_src/build
RUN ../configure --jobs=4 --prefix=/opt/manta
RUN make -j4 install

## Make directory structure
RUN mkdir -p /home/participant/Course_Materials/Day1
RUN mkdir -p /home/participant/Course_Materials/Day2
RUN mkdir -p /home/participant/Course_Materials/Day3
RUN mkdir -p /home/participant/Course_Materials/Day4

## Install required R packages
COPY installBioCPkgs.R /home/participant/Course_Materials/
RUN R -f /home/participant/Course_Materials/installBioCPkgs.R


## Populate directories for each day
COPY Day1/* /home/participant/Course_Materials/Day1/
COPY Day2/* /home/participant/Course_Materials/Day2/
COPY Day3/* /home/participant/Course_Materials/Day3/
COPY Day4/* /home/participant/Course_Materials/Day4/

## Create data, reference data directories
## These will need to be mounted with local directories containing the data when running the container
## scripts are included to download the relevant files

RUN mkdir -p /data/test/
RUN mkdir -p /data/hapmap/
RUN mkdir /reference_data/

## Create a directory for software (i.e. annovar)
## annovar cannot be included in the container due to license restrictions

RUN mkdir -p /home/participant/Course_Materials/software/annovar

## Copy download scripts

COPY download-hapmap-data.sh /home/participant/Course_Materials/
COPY download-ref-data.sh /home/participant/Course_Materials/
COPY download-test-data.sh /home/participant/Course_Materials/

VOLUME /data/
VOLUME /reference_data/

WORKDIR /home/participant/Course_Materials/