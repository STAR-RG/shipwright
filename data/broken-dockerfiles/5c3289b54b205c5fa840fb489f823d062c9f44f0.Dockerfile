# NanoOK Dockerfile
FROM ubuntu:14.04
MAINTAINER Richard Leggett <richard.leggett@earlham.ac.uk>

RUN echo "deb http://cran.cnr.berkeley.edu/bin/linux/ubuntu trusty/" >> /etc/apt/sources.list
RUN apt-get update
RUN apt-get install -y --force-yes r-base
RUN apt-get install -y --force-yes r-cran-ggplot2
RUN apt-get install -y hdf5-tools
RUN apt-get install -y texlive
RUN apt-get install -y texlive-latex-extra
RUN apt-get install -y default-jre
RUN apt-get install -y git
ADD http://last.cbrc.jp/last-761.zip /usr/
RUN cd /usr ; unzip last-761 ; cd last-761 ; make ; make install
RUN cd /usr ; git clone https://github.com/lh3/bwa.git
RUN cd /usr/bwa ; make ; cp bwa /usr/local/bin
RUN cd /usr ; git clone https://github.com/TGAC/NanoOK
ENV NANOOK_DIR="/usr/NanoOK"
RUN echo "export PATH=/usr/NanoOK/bin:${PATH}" >> ~/.bashrc
RUN Rscript -e "install.packages('ggplot2', repos='https://cran.ma.imperial.ac.uk/')"
RUN Rscript -e "install.packages('ggmap', repos='https://cran.ma.imperial.ac.uk/')"
RUN Rscript -e "install.packages('plyr', repos='https://cran.ma.imperial.ac.uk/')"
RUN Rscript -e "install.packages('scales', repos='https://cran.ma.imperial.ac.uk/')"
RUN Rscript -e "install.packages('gridExtra', repos='https://cran.ma.imperial.ac.uk/')"
RUN Rscript -e "install.packages('reshape', repos='https://cran.ma.imperial.ac.uk/')"