FROM alpine:3.7

LABEL maintainer="jeffreystoke <jeffctor@gmail.com>"

# use your favourite mirrors
# RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apk/repositories

# home
ENV HOME=/home/gns3
# gns3 server and deps build dir
ENV BUILD_DIR=${HOME}/build
# images, appliances, projects dir
ENV IMAGES_DIR=/images APPLIANCES_DIR=/appliances PROJECTS_DIR=/projects

RUN adduser -h ${HOME} gns3 -D

# add gns3 server user data folders
RUN mkdir -p ${BUILD_DIR} && \
    mkdir -p ${IMAGES_DIR} ${APPLIANCES_DIR} ${PROJECTS_DIR} && \
    chown -R gns3:gns3 ${IMAGES_DIR} ${APPLIANCES_DIR} ${PROJECTS_DIR} ${HOME} && \
    chmod -R a+x /usr/local/bin/

# entrypoint file
ADD ./scripts /

# install gns3 server
ADD ./gns3server ${HOME}/server
ADD ./server.conf ${HOME}/server.conf

# add 32bit support for iou
ADD ./bin/libc-i386.tar.gz /
ADD ./dynamips ${BUILD_DIR}/dynamips
ADD ./iniparser ${BUILD_DIR}/iniparser 
ADD ./iouyap ${BUILD_DIR}/iouyap
ADD ./ubridge ${BUILD_DIR}/ubridge
ADD ./bin/vpcs_0.8b_Linux64 /usr/local/bin/vpcs
ADD ./container.mk ${BUILD_DIR}/Makefile

WORKDIR ${BUILD_DIR}

# install necessary packages and build
RUN apk add --update --no-cache \
    python3 py3-psutil py3-prompt_toolkit libelf-dev libpcap-dev linux-headers \
    libcap bison flex build-base make cmake wget tar xz sudo && \
    make && \
    cd /home/gns3/server && python3 setup.py install && \
    apk del build-base make cmake wget tar xz linux-headers sudo && \
    cd / && \
    rm -rf ${BUILD_DIR} ${HOME}/server

RUN chown -R root:root /usr/local/bin

VOLUME [ "/appliances", "/projects", "/images" ]

# expose gns3 server port
EXPOSE 3080
# expose console port
EXPOSE 5000-10000

RUN chmod +x /start.sh

STOPSIGNAL SIGTERM

ENTRYPOINT [ "/start.sh" ]
