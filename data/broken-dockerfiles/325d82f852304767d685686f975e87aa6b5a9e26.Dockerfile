# Heavy-weight docker file for development on OmniC
FROM python:3.6.2-stretch
MAINTAINER michaelb <michaelpb@gmail.com>

ENV PYTHONUNBUFFERED 1

# NOTE: Node.js is not version locked, see #47
RUN curl -sL http://deb.nodesource.com/setup_6.x | bash -

# Install system reqs
RUN apt-get update && apt-get install -y \
    imagemagick=8:6.9.7.4+dfsg-11+deb9u1 \
    inkscape=0.92.1-1 \
    meshlab=1.3.2+dfsg1-3 \
    ffmpeg=7:3.2.7-1~deb9u1 \
    ffmpegthumbnailer=2.1.1-0.1+b3 \
    pandoc=1.17.2~dfsg-3 \
    nodejs=6* \
    openbabel=2.3.2+dfsg-3 \
    highlight=3.18-3+b5 \
    unoconv=0.7-1.1

RUN npm install -g \
    babel-cli@6.24.1 \
    babel-preset-es2015@6.24.1 \
    browserify@14.4.0 \
    jsc3d@0.1.8 \
    uglify-js@3.0.20

# Setup python reqs
COPY ./test/requirements.txt /requirements.txt
RUN pip install --no-cache-dir -r /requirements.txt \
    && rm /requirements.txt

# Setup code directory
ADD . /app
WORKDIR /app

EXPOSE 8080

CMD ./bin/omnic runserver --host=0.0.0.0 --port=8080
