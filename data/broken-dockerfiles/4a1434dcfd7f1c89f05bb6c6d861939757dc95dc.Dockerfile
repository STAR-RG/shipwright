FROM ubuntu:18.04 as builder

RUN apt update \
    && apt install -y build-essential pkg-config libssl-dev zlib1g-dev uuid-dev wget checkinstall \
    && rm -rf /var/lib/apt/lists/*

RUN wget https://github.com/Kitware/CMake/releases/download/v3.15.5/cmake-3.15.5-Linux-x86_64.sh
RUN bash cmake-3.15.5-Linux-x86_64.sh --skip-license

COPY . /xeus-fift/

WORKDIR /xeus-fift/build
RUN cmake ..
RUN make

RUN export XFIFT_VERSION=$(bash /xeus-fift/scripts/xfift_version.sh) \
    && echo "Jupyter kernel for the Fift language\n" > description-pak \
    && checkinstall \
        --pkgname="xeus-fift" \
        --pkgversion=$XFIFT_VERSION \
        --pkgrelease="1" \
        --arch="amd64" \
        --pkglicense="GPL-3" \
        --pkgsource="https://github.com/m-kus/xeus-fift" \
        --maintainer="mz@baking-bad.org" \
        --install=no -y -D -d2 make install \
    && mv xeus-fift_$XFIFT_VERSION-1_amd64.deb xeus-fift.deb


FROM python:3.7-slim-buster

RUN pip install notebook

COPY --from=builder /xeus-fift/build/xeus-fift.deb /tmp/xeus-fift.deb
RUN dpkg -i /tmp/xeus-fift.deb

RUN useradd -ms /bin/bash jupyter
USER jupyter
WORKDIR /home/jupyter

EXPOSE 8888
ENTRYPOINT [ "jupyter",  "notebook", "--port=8888", "--ip=0.0.0.0", "--no-browser", "--no-mathjax"]
