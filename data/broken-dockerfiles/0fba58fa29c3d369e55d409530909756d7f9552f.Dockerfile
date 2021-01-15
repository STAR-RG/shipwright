FROM pditommaso/dkrbase:1.1

MAINTAINER Paolo Di Tommaso <paolo.ditommaso@gmail.com>
  
#
# Exonerate
#
RUN wget -q http://www.ebi.ac.uk/sites/ebi.ac.uk/files/groups/flicek/exonerate/exonerate-2.2.0-x86_64.tar.gz && \
  tar xf exonerate-2.2.0-x86_64.tar.gz && \
  mv exonerate-2.2.0-x86_64 /opt/ && \
  rm -rf exonerate-2.2.0-x86_64.tar.gz && \
  ln -s /opt/exonerate-2.2.0-x86_64/ /opt/exonerate

#
# BLAST
#
RUN wget -q ftp://ftp.ncbi.nlm.nih.gov/blast/executables/blast+/2.2.29/ncbi-blast-2.2.29+-x64-linux.tar.gz && \
    tar xf ncbi-blast-2.2.29+-x64-linux.tar.gz && \
    mv ncbi-blast-2.2.29+ /opt/ && \
    rm -rf ncbi-blast-2.2.29+-x64-linux.tar.gz && \
    ln -s /opt/ncbi-blast-2.2.29+/ /opt/blast

#
# CHR_SUBSEQ
# 
RUN wget -q -O /bin/chr_subseq http://www.tcoffee.org/Packages/Archive/chr_subseq && \
  chmod +x /bin/chr_subseq; 
  
#
# Installing WU-BLAST
#  
RUN wget -q http://www.tcoffee.org/Packages/Archive/wublast-060504-blast2.linux26-x64.tar.gz && \
  mkdir /opt/wu-blast && \
  tar xf wublast-060504-blast2.linux26-x64.tar.gz -C /opt/wu-blast/ && \
  find /opt/wu-blast/  -type l | grep -v BLOSUM | xargs rm &&  \
  rm -rf wublast-060504-blast2.linux26-x64.tar.gz && \
  ln -s /opt/wu-blast/blasta /opt/wu-blast/wu-blastn

#
# T-Coffee 
#
RUN wget -q http://www.tcoffee.org/Packages/Archive/tcoffee-Version_10.00.r1613.tar.gz && \
  tar xf tcoffee-Version_10.00.r1613.tar.gz -C /opt && \
  rm -rf tcoffee-Version_10.00.r1613.tar.gz
  
#
# Perl modules required by T-Coffee
# 
RUN cpanm -q -n Env Net::SSLeay XML::Simple SOAP::Lite && \
  rm -rf /root/.cpanm/work/

#
# Add local scripts
#
ADD bin/exonerateRemapping.pl /usr/local/bin/
ADD bin/repeat.pl /usr/local/bin/
ADD bin/sim2matrix.pl /usr/local/bin/

#
# Finalize environment
#
ENV PATH /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/blast/bin:/opt/exonerate/bin:/opt/tcoffee/bin:/opt/wu-blast
ENV TMP /tmp
ENV CACHE_4_TCOFFEE /tmp/cache/
ENV LOCKDIR_4_TCOFFEE /tmp/lck/
ENV TMP_4_TCOFFEE /tmp/tmp/
ENV DIR_4_TCOFFEE /opt/tcoffee
ENV MAFFT_BINARIES /opt/tcoffee/plugins/linux/
ENV EMAIL_4_TCOFFEE tcoffee.msa@gmail.com
ENV WUBLASTMAT /opt/wu-blast/matrix/
ENV WUBLASTFILTER /opt/wu-blast/filter/


RUN chown -R root:root /opt/*; chown -R root:root /usr/local/bin/*
