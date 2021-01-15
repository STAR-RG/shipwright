FROM ubuntu

# Get All Dendencies from DPKG for zmq & mongrel2 
RUN apt-get -qq -y update && apt-get -q -y install \
    curl \
    build-essential \
    sqlite3 \
    libsqlite3-dev \
    uuid-dev \
    libjson0-dev \
    python2.7-minimal \
    unzip 

# Install ZMQ
RUN curl -L https://github.com/zeromq/libzmq/releases/download/v4.2.1/zeromq-4.2.1.tar.gz  \
    | tar xz \
    && cd zero* \
    && ./configure \
    && make \
    && make install \
    && ldconfig -v

# Install Mongrel2
RUN curl -L https://github.com/mongrel2/mongrel2/releases/download/v1.11.0/mongrel2-v1.11.0.tar.bz2 \
    | tar xj \
    && cd mongrel* \
    && make install

# Install CPP bindings for JSON, ZMQ, Mongrel2, 
RUN curl -L https://github.com/open-source-parsers/jsoncpp/archive/1.7.7.tar.gz \
    | tar xz \
    && cd jsoncpp-1.7.7 \
    && /usr/bin/python2.7 amalgamate.py \
    && cd ..
RUN curl -L https://github.com/zeromq/cppzmq/archive/v4.2.1.tar.gz \
    | tar xz \
    && cp cppzmq-4.2.1/zmq*.hpp /usr/local/include
RUN curl -L https://github.com/condnsdmatters/mongrel2-cpp/archive/master.zip > mongrel2-cpp.zip \
    && unzip mongrel2-cpp.zip -d mongrel2-cpp \
    && cd mongrel2-cpp/mongrel2-cpp-master \
    && make all 

# Build directory structure for Smithers
RUN mkdir -p smithers/obj/ext \
             smithers/external/include \
             smithers/external/lib \
             smithers/external/src \
             smithers/logs 

# Copy dependencies in to structure
RUN cp mongrel2-cpp/mongrel2-cpp-master/libm2pp.a smithers/external/lib/ \
    && cp mongrel2-cpp/mongrel2-cpp-master/lib/m2pp*.hpp smithers/external/include \
    && cp -R jsoncpp-1.7.7/dist/json/ smithers/external/include \
    && cp jsoncpp-1.7.7/dist/jsoncpp.cpp smithers/external/src/

# Copy the source & config for Smithers
COPY src smithers/src
COPY main.m.cpp Makefile smithers/

# Build this badboy
RUN cd smithers && make all 

# Copy the runtime configs
RUN mkdir -p /etc/mongrel2/run /etc/mongrel2/logs && cp smithers/smithers.tsk /etc/mongrel2 
ADD pbb_mongrel.conf /etc/mongrel2/pbb_mongrel.conf
RUN chown -R www-data /etc/mongrel2

# BELOW HERE JUST TESTING
ADD mongrel2-start /usr/sbin/mongrel2-start
RUN chmod 775 /usr/sbin/mongrel2-start

COPY clients clients/
EXPOSE 6767 9950 9997 9996

# Give www-data user a shell
RUN chsh -s /bin/bash www-data

ENTRYPOINT [ "mongrel2-start" ]

