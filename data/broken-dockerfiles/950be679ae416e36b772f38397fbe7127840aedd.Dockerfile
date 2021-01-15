FROM gcc:5.3.0

# Download sources
RUN cd /opt && git clone https://github.com/rdfhdt/hdt-cpp.git hdt
RUN cd /opt && curl -O http://fallabs.com/kyotocabinet/pkg/kyotocabinet-1.2.76.tar.gz
RUN cd /opt && tar -xvzf kyotocabinet-1.2.76.tar.gz && mv kyotocabinet-1.2.76 kyotocabinet && rm kyotocabinet-1.2.76.tar.gz
RUN apt-get update

# Install kyoto cabinet
RUN apt-get -y install liblzo2-dev liblzma-dev zlib1g-dev build-essential
RUN cd /opt/kyotocabinet && ./configure –enable-zlib –enable-lzo –enable-lzma && make && make install

# install raptor2
RUN apt-get install -y libraptor2-dev

# Install Serd
RUN apt-get install -y libserd-dev

# Enable optional dependencies in Makefile
RUN cd /opt/hdt/hdt-lib && sed -i "s/#KYOTO_SUPPORT=true/KYOTO_SUPPORT=true/" Makefile

# Install HDT tools
RUN cd /opt/hdt/hdt-lib && make

# Expose binaries
ENV PATH /opt/hdt/hdt-lib/tools:$PATH

# Default command
CMD ["/bin/echo", "Available commands: rdf2hdt hdt2rdf hdtSearch"]

