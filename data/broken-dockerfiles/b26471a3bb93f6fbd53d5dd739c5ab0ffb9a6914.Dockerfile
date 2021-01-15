FROM ubuntu:20.04

# ----
ARG DEBIAN_FRONTEND=noninteractive
# for apt-get tzdata not asked enter timezone from keyboard

RUN apt-get update && apt-get install --yes \
osm2pgsql \
software-properties-common \
wget\
git

RUN apt-get install --yes python3 python3-pip

RUN git clone https://github.com/trolleway/osmot.git
WORKDIR osmot
RUN pip install -r requirements.txt

#ENTRYPOINT ["/routing_preprocessing/check_db.sh"]
#CMD ["/bin/bash" , "/osmtram_preprocessing/indocker.sh"]
