# Set Ubuntu base image
FROM ubuntu:14.04

# Define the maintainer of the image
MAINTAINER Geoffrey Hannigan <ghannig@umich.edu>

# Download 
RUN  apt-get update \
  && apt-get install -y wget \
  && apt-get install -y perl
RUN apt-get install -y python-pip python-dev build-essential
RUN pip install --upgrade pip
RUN pip install Cython

###########
# PRINSEQ #
###########
# This is a lightweight dependency for DeconSeq
# Download the file
RUN wget -O /home/prinseq-lite-0.20.4.tar.gz http://pilotfiber.dl.sourceforge.net/project/prinseq/standalone/prinseq-lite-0.20.4.tar.gz
# Unzip
RUN tar -zxvf /home/prinseq-lite-0.20.4.tar.gz
RUN rm /home/prinseq-lite-0.20.4.tar.gz

#################
# FASTX TOOLKIT #
#################
# Download from the website
RUN wget -O /home/fastx_toolkit_0.0.13_binaries_Linux_2.6_amd64.tar.bz2 http://hannonlab.cshl.edu/fastx_toolkit/fastx_toolkit_0.0.13_binaries_Linux_2.6_amd64.tar.bz2
# Uncompress that toolkit
RUN tar -vxjf /home/fastx_toolkit_0.0.13_binaries_Linux_2.6_amd64.tar.bz2
RUN rm /home/fastx_toolkit_0.0.13_binaries_Linux_2.6_amd64.tar.bz2
# Binaries can be found in `./bin`

############
# DECONSEQ #
############
# Download the standalone deconseq program
RUN wget -O /home/deconseq-standalone-0.4.3.tar.gz http://jaist.dl.sourceforge.net/project/deconseq/standalone/deconseq-standalone-0.4.3.tar.gz
# Uncompress the file
RUN tar -zxvf /home/deconseq-standalone-0.4.3.tar.gz
RUN rm /home/deconseq-standalone-0.4.3.tar.gz
RUN mkdir ./deconseq-standalone-0.4.3/db
# Download human reference dataset
WORKDIR "./deconseq-standalone-0.4.3/db"
RUN for i in $(seq 1 22) X Y MT; do wget ftp://ftp.ncbi.nih.gov/genomes/H_sapiens/Assembled_chromosomes/seq/hs_ref_GRCh38.p7_chr$i.fa.gz; done
RUN for i in $(seq 1 22) X Y MT; do gzip -dvc hs_ref_GRCh38.p7_chr$i.fa.gz >>hs_ref_GRCh38_p7.fa; rm hs_ref_GRCh38.p7_chr$i.fa.gz; done
RUN cat hs_ref_GRCh38_p7.fa | perl -p -e 's/N\n/N/' | perl -p -e 's/^N+//;s/N+$//;s/N{200,}/\n>split\n/' >hs_ref_GRCh38_p7_split.fa; rm hs_ref_GRCh38_p7.fa
RUN perl ../../prinseq-lite-0.20.4/prinseq-lite.pl -log -verbose -fasta hs_ref_GRCh38_p7_split.fa -min_len 200 -ns_max_p 10 -derep 12345 -out_good hs_ref_GRCh38_p7_split_prinseq -seq_id hs_ref_GRCh38_p7_ -rm_header -out_bad null; rm hs_ref_GRCh38_p7_split.fa
RUN ../bwa64 index -p hs_ref_GRCh38_p7 -a bwtsw hs_ref_GRCh38_p7_split_prinseq.fasta >bwa.log 2>&1 &
# Download mouse reference dataset
RUN for i in $(seq 1 22) X Y MT; do wget ftp://ftp.ncbi.nih.gov/genomes/Mus_musculus/Assembled_chromosomes/seq/mm_ref_GRCm38.p3_chr$i.fa.gz; done
RUN for i in $(seq 1 22) X Y MT; do gzip -dvc mm_ref_GRCm38.p3_chr$i.fa.gz >>mm_ref_GRCm38.p3.fa; rm mm_ref_GRCm38.p3_chr$i.fa.gz; done
RUN cat mm_ref_GRCm38.p3.fa | perl -p -e 's/N\n/N/' | perl -p -e 's/^N+//;s/N+$//;s/N{200,}/\n>split\n/' >mm_ref_GRCm38.p3_split.fa; rm mm_ref_GRCm38.p3.fa
RUN perl ../../prinseq-lite-0.20.4/prinseq-lite.pl -log -verbose -fasta mm_ref_GRCm38.p3_split.fa -min_len 200 -ns_max_p 10 -derep 12345 -out_good mm_ref_GRCm38.p3_split_prinseq -seq_id mm_ref_GRCm38.p3_ -rm_header -out_bad null; rm mm_ref_GRCm38.p3_split.fa
RUN ../bwa64 index -p mm_ref_GRCm38.p3 -a bwtsw mm_ref_GRCm38.p3_split_prinseq.fasta >bwa.log 2>&1 &

############
# CUTADAPT #
############
WORKDIR "/home/"
RUN wget -O /home/cutadapt-1.10 https://github.com/marcelm/cutadapt/archive/v1.10.tar.gz
RUN tar -zxvf /home/cutadapt-1.10
WORKDIR "/home/cutadapt-1.10/"
RUN python2.7 ./setup.py install --user

ADD ./pakbin/* /home/

############
# Clean Up #
############

# Clean up some of the dependencies that we no longer need
RUN pip uninstall -y Cython
RUN apt-get purge -y python-pip python-dev build-essential wget
RUN apt-get autoremove -y

#######################
# SET IMAGE DIRECTORY #
#######################

WORKDIR /data/
