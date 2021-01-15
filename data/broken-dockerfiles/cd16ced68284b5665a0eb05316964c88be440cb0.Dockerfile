FROM bdevloed/eye:latest

RUN apt-get update -y
RUN apt-get install -y build-essential
RUN apt-get install -y python
RUN apt-get install -y python-pip
RUN apt-get install -y git
RUN apt-get install -y wget
RUN apt-get -y install unzip

# Install RDFLib
RUN pip install rdflib
RUN pip install html5lib

# Install Serd
RUN git clone https://github.com/drobilla/serd.git
WORKDIR serd
RUN ./waf configure
RUN ./waf
RUN ./waf install

WORKDIR /

# Install CTurtle
RUN apt-get -y install flex
RUN wget -O "cturtle.zip" "https://github.com/melgi/cturtle/archive/v1.0.5.zip"
RUN unzip "cturtle.zip" -d "./"
RUN rm "cturtle.zip"
RUN cd "./cturtle-1.0.5" && make install

WORKDIR /WebsiteToRDF

COPY ontologies ontologies
COPY extract-website-data .
COPY rdfa2ttl .
COPY docker.sh .

ENTRYPOINT ["./docker.sh"]
