FROM ubuntu
RUN apt-get update
RUN apt-get --assume-yes install \
    librrd-dev \
    libxml2-dev \
    libglib2.0 \
    libcairo2-dev \
    libpango1.0-dev \
    python-dev \
    python-setuptools \
    build-essential
RUN easy_install pip
WORKDIR /build/
COPY . /build/
RUN pip install -r requirements.txt && python setup.py install
EXPOSE 5000
CMD ["./manage.py", "runserver"]
