FROM phusion/baseimage
MAINTAINER Dan Leehr <dan.leehr@duke.edu>

RUN apt-get update && apt-get install -y \
  python \
  python-dev \
  libffi-dev \
  libssl-dev \
  python-pip

COPY requirements.txt /
RUN pip install -r requirements.txt
COPY docker-pipeline /docker-pipeline
WORKDIR /docker-pipeline
ENTRYPOINT ["python", "pipeline.py"]
CMD ["-h"]
