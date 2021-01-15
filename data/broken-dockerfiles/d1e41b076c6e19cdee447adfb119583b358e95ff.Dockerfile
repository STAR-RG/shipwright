FROM duckll/ctf-box:mid

# apt
RUN apt update \
&& apt install -y \
   automake \
   bison \
   libglib2.0-dev \
   libtool-bin \
   libpcre++-dev \
   nmap \
   p7zip-full \
   pcregrep \

# pip
&& pip2 install \
   angr \
   # distorm3 \
   gmpy \
   # openpyxl \
   pycrypto \
   Pillow \
   # sympy \
   # ujson \
   xortool \
   # yara-python \


# afl
&& cd /tmp \
&& git clone https://github.com/google/AFL.git --depth 1 \
&& cd AFL \
&& make \
&& make install \
&& cd ./qemu_mode \
&& ./build_qemu_support.sh \

# binwalk
&& cd /tmp \
&& git clone https://github.com/devttys0/binwalk.git --depth 1 \
&& cd ./binwalk \
&& ./setup.py install \

# pintool
# && wget http://software.intel.com/sites/landingpage/pintool/downloads/pin-3.4-97438-gf90d1f746-gcc-linux.tar.gz \
# && tar -zxvf pin-3.4-97438-gf90d1f746-gcc-linux.tar.gz \
# && rm pin-3.4-97438-gf90d1f746-gcc-linux.tar.gz \
# && mv pin-3.4-97438-gf90d1f746-gcc-linux pin \
# && echo 'export PATH="/pin:$PATH"' >> ~/.bashrc \
# && cd pin/source/tools \
# && make \

# volatility
# && cd / \
# && git clone https://github.com/volatilityfoundation/volatility.git \
# && cd ./volatility \
# && python setup.py install \
# && cd ../ \
# && rm -rf ./volatility \

# cleanup
&& apt clean \
&& rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
