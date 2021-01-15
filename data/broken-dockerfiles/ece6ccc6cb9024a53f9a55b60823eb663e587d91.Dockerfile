FROM tensorflow/tensorflow:1.14.0-py3-jupyter

RUN apt-get update && apt-get install -y wget git pkg-config libprotobuf-dev protobuf-compiler libjson-c-dev intltool libx11-dev libxext-dev
RUN pip3 install --no-cache-dir six scipy tensorflow-hub tensorflow-probability==0.7 dm-sonnet==1.35

RUN wget https://github.com/Kitware/CMake/releases/download/v3.15.4/cmake-3.15.4-Linux-x86_64.sh \
    -q -O /tmp/cmake-install.sh \
    && chmod u+x /tmp/cmake-install.sh \
    && mkdir /usr/bin/cmake \
    && /tmp/cmake-install.sh --skip-license --prefix=/usr/bin/cmake \
    && rm /tmp/cmake-install.sh

ENV PATH="/usr/bin/cmake/bin:${PATH}"

RUN git clone https://github.com/deepmind/spiral.git
WORKDIR /tf/spiral

RUN git submodule update --init --recursive \
    && wget -c https://github.com/mypaint/mypaint-brushes/archive/v1.3.0.tar.gz -O - | tar -xz -C third_party \
    && git clone https://github.com/dli/paint third_party/paint \
    && patch third_party/paint/shaders/setbristles.frag third_party/paint-setbristles.patch

COPY setup.patch setup.patch
RUN patch setup.py setup.patch

COPY cmakelists.patch cmakelists.patch
RUN patch CMakeLists.txt cmakelists.patch

RUN python3 setup.py develop --user

RUN apt-get autoremove -y && apt-get remove -y wget git pkg-config && apt-get autoremove -y

CMD ["bash", "-c", "source /etc/bash.bashrc && jupyter notebook --notebook-dir=/tf/spiral/notebooks --ip 0.0.0.0 --no-browser --allow-root"]