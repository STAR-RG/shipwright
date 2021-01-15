#
# Our base image
FROM alpine:latest

MAINTAINER Anastasios Selalmazidis <t.selalmasidis@gmail.com>

#
# Install python-pip
RUN apk add --update py2-pip

#
# Add files
#
ADD run.py /isthmos/
ADD app /isthmos/app/
ADD requirements.txt /isthmos/

#
# Install requirements
#
RUN pip install --no-cache-dir -U pip
RUN pip install --no-cache-dir -r /isthmos/requirements.txt

#
# Run app
#
WORKDIR /isthmos
CMD python run.py
