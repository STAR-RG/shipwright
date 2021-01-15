FROM python:3.6-slim-stretch

RUN apt-get update && apt-get install -y python3-dev gcc \
    && rm -rf /var/lib/apt/lists/*

#install ffmpeg (takes a long time...need to figure out a better solution)
RUN apt-get -y update && apt-get install -y wget nano git build-essential yasm pkg-config

#install libsndfile (need to fix)
#RUN apt-get install libsndfile1

# RUN  apt-get install libsndfile1

ADD requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt


# Compile and install ffmpeg from source
RUN git clone https://github.com/FFmpeg/FFmpeg /root/ffmpeg && \
    cd /root/ffmpeg && \
    ./configure --enable-nonfree --disable-shared --extra-cflags=-I/usr/local/include && \
    make -j8 && make install -j8

# If you want to add some content to this image because the above takes a LONGGG time to build
ARG CACHEBREAK=1

COPY app app/

RUN python app/server.py

EXPOSE 8080

CMD ["python", "app/server.py", "serve"]
