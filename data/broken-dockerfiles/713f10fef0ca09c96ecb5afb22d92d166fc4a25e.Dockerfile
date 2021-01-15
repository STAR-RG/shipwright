#
#  From this base-image / starting-point
#
FROM debian:testing

#
#  Authorship
#
MAINTAINER ss34@sanger.ac.uk

#
# Pull in packages from testing
#
RUN apt-get update -qq

#
# Install dependencies
# we need blast2 for ABACAS2 as it does not use BLAST+ yet
#
RUN apt-get install build-essential hmmer lua5.1 ncbi-blast+ blast2 snap \
                    unzip mummer infernal exonerate mafft fasttree \
                    circos libsvg-perl libgd-svg-perl python-setuptools \
                    libc6-i386 lib32stdc++6 lib32gcc1 netcat genometools \
                    last-align libboost-iostreams-dev libgslcblas0 libgsl-dev \
                    libcolamd2 liblpsolve55-dev libstdc++6 aragorn tantan \
                    libstorable-perl libbio-perl-perl libsqlite3-dev \
                    --yes
RUN ln -fs /usr/bin/fasttree /usr/bin/FastTree
RUN ln -s /usr/lib/snap/snap /usr/local/bin/snap

# 
# Install AUGUSTUS
# 
RUN apt-get install augustus --yes


# 
# Install GenomeTools
# 
RUN apt-get install genometools --yes


#
# Install and configure OrthoMCL
#
ADD http://www.orthomcl.org/common/downloads/software/unsupported/v1.4/ORTHOMCL_V1.4_mcl-02-063.tar /opt/omcl.tar
RUN cd /opt && \
    tar -xvf omcl.tar && \
    tar -xzvf mcl-02-063.tar.gz && \
    rm -f omcl.tar mcl-02-063.tar.gz && \
    cd /opt/mcl-* && \
    ./configure && \
    make -j3 && \
    make install && \
    cd / && \
    rm -rf /opt/mcl*
RUN sed -i 's/our .PATH_TO_ORTHOMCL.*=.*/our $PATH_TO_ORTHOMCL = ".\/";/' /opt/ORTHOMCLV1.4/orthomcl_module.pm && \
    sed -i 's/our .BLASTALL.*=.*/our $BLASTALL = "\/usr\/bin\/blastall";/' /opt/ORTHOMCLV1.4/orthomcl_module.pm && \
    sed -i 's/our .FORMATDB.*=.*/our $FORMATDB = "\/usr\/bin\/formatdb";/' /opt/ORTHOMCLV1.4/orthomcl_module.pm && \
    sed -i 's/our .MCL.*=.*/our $MCL = "\/usr\/local\/bin\/mcl";/' /opt/ORTHOMCLV1.4/orthomcl_module.pm

#
# Install Gblocks
#
ADD http://molevol.cmima.csic.es/castresana/Gblocks/Gblocks_Linux64_0.91b.tar.Z /opt/gblocks64.tar.Z
RUN cd /opt && \
    tar -xzvf gblocks64.tar.Z && \
    rm -rf gblocks64.tar.Z && \
    cp Gblocks_0.91b/Gblocks /usr/bin/Gblocks && \
    chmod 755 /usr/bin/Gblocks

#
# get GO OBO file
#
ADD http://geneontology.org/ontology/go.obo /opt/go.obo

#
# get Pfam pHMMs
#
RUN mkdir -p /opt/pfam
ADD http://ftp.ebi.ac.uk/pub/databases/Pfam/current_release/Pfam-A.hmm.gz /opt/pfam/Pfam-A.hmm.gz
RUN cd /opt/pfam && \
    gunzip Pfam-A.hmm.gz && \
    hmmpress Pfam-A.hmm && \
    rm -f Pfam-A.hmm

# 
# copy data dir
#
RUN mkdir -p /opt/data
ADD ./data /opt/data

#
# install RATT (keep up to date from build directory)
#
ADD ./RATT /opt/RATT

#
# install ABACAS (keep up to date from build directory)
#
ADD ./ABACAS2 /opt/ABACAS2

ENV AUGUSTUS_CONFIG_PATH /usr/share/augustus/config
ENV RATT_HOME /opt/RATT
ENV GT_RETAINIDS yes
ENV PERL5LIB /opt/ORTHOMCLV1.4/:/opt/RATT/:/opt/ABACAS2/:$PERL5LIB
ENV PATH /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/share/augustus/bin:/usr/share/augustus/scripts:/opt/ORTHOMCLV1.4:/opt/RATT:/opt/ABACAS2:$PATH
