FROM ubuntu:14.04

RUN apt-get update -y && apt-get install --no-install-recommends -y -q \
        build-essential \
        libpq-dev \
        python \
        python-dev \
        python-pip \
        libjpeg-dev \
    && apt-get clean \
    && apt-get autoclean \
    && apt-get autoremove -y \
    && rm -rf /var/lib/{apt,dpkg,cache,log}/

WORKDIR /src/
ADD . /src/

RUN pip install pytest pytest-cov pytest-pep8 pytest-flakes
RUN pip install -e .[develop]

CMD ["python"]
