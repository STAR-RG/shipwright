FROM ubuntu:latest

# Build essentials
RUN apt-get update
RUN apt-get install -y curl build-essential

# Mecab
RUN curl -O https://mecab.googlecode.com/files/mecab-0.996.tar.gz
RUN tar -xzf mecab-0.996.tar.gz
RUN cd mecab-0.996; ./configure --enable-utf8-only; make; make install; ldconfig

# Ipadic
RUN curl -O https://mecab.googlecode.com/files/mecab-ipadic-2.7.0-20070801.tar.gz
RUN tar -xzf mecab-ipadic-2.7.0-20070801.tar.gz
RUN cd mecab-ipadic-2.7.0-20070801; ./configure --with-charset=utf8; make; make install
RUN echo "dicdir = /usr/local/lib/mecab/dic/ipadic" > /usr/local/etc/mecabrc

# Clean up
RUN apt-get remove -y build-essential
RUN rm -rf mecab-0.996.tar.gz*
RUN rm -rf mecab-ipadic-2.7.0-20070801*

