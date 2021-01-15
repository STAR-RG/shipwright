FROM ubuntu:16.04

# --------------------------- ubuntu ------------------------------------------
RUN apt-get -y update
RUN	apt-get -y install git build-essential cmake clang wget

# --------------------------- sexpr -------------------------------------------
RUN git clone https://github.com/WebAssembly/sexpr-wasm-prototype.git
# SHA from branch binary_0xa
RUN cd sexpr-wasm-prototype && \
	git checkout 98729df && \
	git submodule update --init
RUN cd sexpr-wasm-prototype && make -j8

# -------------------------- node ---------------------------------------------
RUN git clone https://github.com/nodejs/node.git
# SHA from branch vee-eight-5.1
RUN cd node && \
	git checkout 61ed0bb && \
	./configure && \
	make -j8

# ------------------------ emscripten -----------------------------------------
RUN wget https://s3.amazonaws.com/mozilla-games/emscripten/releases/emsdk-portable.tar.gz
RUN tar -xvf emsdk-portable.tar.gz
RUN cd /emsdk_portable && \
	./emsdk update && \
	./emsdk install sdk-incoming-64bit && \
	./emsdk activate sdk-incoming-64bit
ENV PATH /binaryen/bin/:/node:/emsdk_portable:/emsdk_portable/clang/fastcomp/build_incoming_64/bin:\
	/emsdk_portable/node/4.1.1_64bit/bin:/emsdk_portable/emscripten/incoming:\
	/node/out/Release/:/sexpr-wasm-prototype/out/:/usr/local/sbin:/usr/local/bin:\
	/usr/sbin:/usr/bin:/sbin:/bin

# ------------------------- binaryen ------------------------------------------
# Last version with 0xa support: 31dd39afd6197743d3ccbb2cfa4276134c6751d2
# wasm-as index.wast > index.wasm
# Produces error: Result = section string of size 110 longer than total section bytes 6 @+8
RUN git clone https://github.com/WebAssembly/binaryen.git
RUN cd /binaryen && cmake . && make

RUN	apt-get -y install vim

# Force binaryen to cache stuff
RUN cd /tmp && \
	echo "int main() { return 0; }" > /tmp/test.c && \
	emcc /tmp/test.c -s BINARYEN=1 -O0 -s ONLY_MY_CODE=1 -o index.js

# ---------------------------- run --------------------------------------------
WORKDIR /src
ENTRYPOINT cd /build && \
	emcc /src/hello_world.c -s BINARYEN=1 -O0 -s ONLY_MY_CODE=1 -o index.js && \
	sexpr-wasm /build/index.wast -o /build/hello_world.wasm && \
	/node/out/Release/node --expose-wasm /src/index.js && \
	chmod ugo+rw *
