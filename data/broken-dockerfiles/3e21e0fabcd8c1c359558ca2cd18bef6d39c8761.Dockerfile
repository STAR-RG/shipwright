
FROM python:alpine

WORKDIR /usr/src/app

COPY requirements.txt ./

RUN apk --no-cache add ca-certificates make \
    && update-ca-certificates \
    && apk --no-cache --virtual .build-dependencies add build-base \
    libffi-dev \
    openssl-dev \
    && pip install --no-cache-dir -r requirements.txt \
    && apk del .build-dependencies

COPY . .

ENTRYPOINT ["/usr/bin/make"]

CMD ["status"]
