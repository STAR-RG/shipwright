FROM frolvlad/alpine-glibc as builder

ENV OTP_VERSION="20.2.2"

RUN set -xe \
    && OTP_DOWNLOAD_URL="https://github.com/erlang/otp/archive/OTP-${OTP_VERSION}.tar.gz" \
    && OTP_DOWNLOAD_SHA256="7614a06964fc5022ea4922603ca4bf1d2cc241f9bd6b7321314f510fd74c7304" \
    && apk add --no-cache --virtual .fetch-deps curl ca-certificates \
    && curl -fSL -o otp-src.tar.gz "$OTP_DOWNLOAD_URL" \
    && echo "$OTP_DOWNLOAD_SHA256  otp-src.tar.gz" | sha256sum -c - \
    && apk add --no-cache --virtual .build-deps \
    dpkg-dev dpkg \
    gcc \
    g++ \
    libc-dev \
    linux-headers \
    make \
    autoconf \
    ncurses-dev \
    openssl-dev \
    unixodbc-dev \
    lksctp-tools-dev \
    tar \
    && export ERL_TOP="/usr/src/otp_src_${OTP_VERSION%%@*}" \
    && mkdir -vp $ERL_TOP \
    && tar -xzf otp-src.tar.gz -C $ERL_TOP --strip-components=1 \
    && rm otp-src.tar.gz \
    && ( cd $ERL_TOP \
    && ./otp_build autoconf \
    && gnuArch="$(dpkg-architecture --query DEB_BUILD_GNU_TYPE)" \
    && ./configure --build="$gnuArch" \
    && make -j$(getconf _NPROCESSORS_ONLN) \
    && make install ) \
    && rm -rf $ERL_TOP \
    && find /usr/local -regex '/usr/local/lib/erlang/\(lib/\|erts-\).*/\(man\|doc\|obj\|c_src\|emacs\|info\|examples\)' | xargs rm -rf \
    && find /usr/local -name src | xargs -r find | grep -v '\.hrl$' | xargs rm -v || true \
    && find /usr/local -name src | xargs -r find | xargs rmdir -vp || true \
    && scanelf --nobanner -E ET_EXEC -BF '%F' --recursive /usr/local | xargs -r strip --strip-all \
    && scanelf --nobanner -E ET_DYN -BF '%F' --recursive /usr/local | xargs -r strip --strip-unneeded \
    && runDeps="$( \
    scanelf --needed --nobanner --format '%n#p' --recursive /usr/local \
    | tr ',' '\n' \
    | sort -u \
    | awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' \
    )" \
    && apk add --virtual .erlang-rundeps $runDeps lksctp-tools \
    && apk del .fetch-deps .build-deps

# elixir expects utf8.
ENV ELIXIR_VERSION="v1.6.0" \
    LANG=C.UTF-8

RUN set -xe \
    && ELIXIR_DOWNLOAD_URL="https://github.com/elixir-lang/elixir/releases/download/${ELIXIR_VERSION}/Precompiled.zip" \
    && ELIXIR_DOWNLOAD_SHA256="f848bc7f88f9c252b3610a9995679889ce18073d0f0a061533c12e622b2ac9e7" \
    && buildDeps=' \
    ca-certificates \
    curl \
    unzip \
    ' \
    && apk --no-cache  add --virtual .build-deps $buildDeps \
    && curl -fSL -o elixir-precompiled.zip $ELIXIR_DOWNLOAD_URL \
    && echo "$ELIXIR_DOWNLOAD_SHA256  elixir-precompiled.zip" | sha256sum -c - \
    && unzip -d /usr/local elixir-precompiled.zip \
    && rm elixir-precompiled.zip \
    && apk del .build-deps

ENV MIX_ENV=prod VERBOSE=1

WORKDIR /app

RUN apk update && apk --no-cache add nodejs git yarn gmp-dev gmp

COPY . .

RUN mix do local.hex --force, \
    local.rebar, \
    deps.get, \
    deps.compile, \
    compile

RUN yarn install && yarn webpack:production || : && mix phx.digest

RUN mix release --env=prod --verbose

FROM elixir:1.6.0-alpine
WORKDIR /root
COPY --from=builder /app/_build/ .
RUN apk update && apk --no-cache add bash
ENV HOST=localhost \
    MNESIA_HOST=bs@127.0.0.1 \
    MNESIA_STORAGE_TYPE=ram_copies \
    PORT=3000 \
    SECRET_KEY_BASE=tbFePEIYrMaNfKmTHZZT9IrdebmVbS3FnCTOp/AAWklO9Jxnhua1YlGaMLzYz2yy
EXPOSE 3000
CMD /root/prod/rel/bs/bin/bs foreground
