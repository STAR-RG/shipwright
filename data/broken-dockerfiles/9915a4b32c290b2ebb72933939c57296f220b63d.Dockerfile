# Use builder image to build and do initial config
FROM alpine:latest as builder
ADD . /
RUN chmod 644 /include/innative/
RUN chmod 644 /scripts/
RUN chmod 644 /wasm_malloc.c
RUN chmod 755 ./build-llvm.sh
RUN apk add --no-cache git
RUN apk add --no-cache clang alpine-sdk
RUN apk add --no-cache cmake
RUN apk add --no-cache python3
RUN apk add --no-cache zlib-dev
RUN /build-llvm.sh
RUN chmod 644 /spec/test/core/
RUN make

FROM alpine:latest
RUN apk add --no-cache libstdc++
RUN apk add --no-cache libgcc
RUN mkdir /innative/
COPY --from=builder /bin/innative-cmd /innative/innative-cmd
COPY --from=builder /bin/innative-test /usr/bin/innative-test
COPY --from=builder /bin/innative-env.a /innative/innative-env.a
COPY --from=builder /bin/innative-env-d.a /innative/innative-env-d.a
COPY --from=builder /bin/innative-stub.a /usr/lib/innative-stub.a
COPY --from=builder /bin/libinnative.so /innative/libinnative.so
RUN cd innative;./innative-cmd -i
RUN rm -rf /innative/
COPY --from=builder ./include/ /usr/include/
COPY --from=builder ./scripts/ /usr/scripts/
COPY --from=builder ./wasm_malloc.c /usr/wasm_malloc.c
COPY --from=builder /spec/test/core/ /usr/spec/test/core/