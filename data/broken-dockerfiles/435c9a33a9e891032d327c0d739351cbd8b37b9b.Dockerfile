FROM <your-repo-name>/cdsw/engine:1
MAINTAINER email@cloudera.com

ENTRYPOINT [ “/bin/bash”, “-c” ]

RUN mkdir /usr/local/cuda
COPY cuda/* cuda/
COPY boost/lib/ /usr/local/lib/
COPY caffe.conf /etc/ld.so.conf.d/
COPY cuda.conf /etc/ld.so.conf.d/
RUN ldconfig
