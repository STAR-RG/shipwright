FROM quay.io/pypa/manylinux1_x86_64

# Install boost
RUN curl -L -O https://dl.bintray.com/boostorg/release/1.70.0/source/boost_1_70_0.tar.gz && \
    tar zxf boost_1_70_0.tar.gz && \
    mkdir -p /boost/include && \
    mv /boost_1_70_0/boost /boost/include && \
    rm boost_1_70_0.tar.gz

ENV BOOST_DIR /boost

COPY . /app
WORKDIR /app

RUN /app/build_wheels.sh

