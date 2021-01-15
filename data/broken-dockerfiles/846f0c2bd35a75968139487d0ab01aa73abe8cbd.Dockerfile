# Compile PHP with static linked dependencies
# to create a single running binary

FROM amazonlinux

ARG PHP_VERSION

RUN yum install \
    autoconf \
    automake \
    libtool \
    wget \
    git \
    m4 \
    re2c \
    libxml2-devel \
    openssl-devel \
    libpng-devel \
    libjpeg-devel \
    mysql \
    curl-devel -y

# need this specific version to build php < 5.5
RUN wget http://ftp.gnu.org/gnu/bison/bison-2.6.4.tar.gz
RUN tar -xvzf bison-2.6.4.tar.gz
WORKDIR /bison-2.6.4
RUN ./configure
RUN make
RUN make install
WORKDIR /
RUN rm -rf bison-*

RUN curl -sL https://github.com/php/php-src/archive/$PHP_VERSION.tar.gz | tar -zxv

WORKDIR /php-src-$PHP_VERSION

RUN git clone https://github.com/ZeWaren/pecl-apd.git
RUN mv pecl-apd ext/apd

RUN ./buildconf --force
RUN ./configure \
    --enable-static=yes \
    --enable-shared=no \
    --disable-all \
    --enable-apd \
    --enable-dom \
    --enable-filter \
    --enable-hash \
    --enable-json \
    --enable-libxml \
    --enable-mbstring \
    --enable-phar \
    --enable-pdo \
    --enable-simplexml \
    --enable-soap \
    --enable-xml \
    --enable-xmlwriter \
    --enable-zip \
    --with-curl \
    --with-gd \
    --with-iconv \
    --with-mysql \
    --with-mysqli \
    --with-pdo-mysql \
    --with-xmlrpc \
    --with-zlib \
    --with-openssl \
    --without-pear \
    --enable-ctype \
    --enable-fileinfo

RUN make -j 5
RUN cp ./sapi/cli/php /usr/bin/

# for debugging inside container via serverless invoke local OR 
# $>php handler.php '{"path":"/wp-admin/","httpMethod":"GET","headers":{"Host":"www.domain.com"},"queryStringParameters":null}'
#RUN curl --silent --location https://rpm.nodesource.com/setup_6.x | bash -                                  
#RUN yum install -y nodejs
#RUN npm install -g serverless serverless-domain-manager

VOLUME /app
WORKDIR /app