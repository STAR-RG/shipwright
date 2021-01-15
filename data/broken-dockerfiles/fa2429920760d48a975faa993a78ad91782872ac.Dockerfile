FROM ubuntu
MAINTAINER Mike Chirico <mchirico@gmail.com>
RUN apt-get update && apt-get install -y \
    python \
    sqlite3 \
    vim  \
    python-setuptools \
    python-dev \
    build-essential python-pip

# Above ref: https://docs.docker.com/engine/userguide/eng-image/dockerfile_best-practices/
#

# Yes, do this twice so it get's cached
RUN pip install --upgrade pip
RUN pip install gunicorn==19.6.0
RUN pip install numpy==1.11.1
RUN pip install pandas==0.18.1

RUN mkdir /src
COPY requirements.txt /src
COPY _loadFacebook.sql /src
COPY grabFacebookData.py /src
COPY combineData.py /src
COPY tokenf.py /src
COPY mainRun.sh /src
COPY LICENSE /src
# Someday we'll forget to update the above
RUN pip install -r /src/requirements.txt


