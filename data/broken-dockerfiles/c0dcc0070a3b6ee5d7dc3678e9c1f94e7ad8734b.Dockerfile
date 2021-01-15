# Need to use an Alpine image that has python 3.5, since WAL-E doesn't
# work well with newer Pythons
FROM alpine:3.5

# Add run dependencies in its own layer
RUN apk add --no-cache --virtual .run-deps python3 lzo curl pv postgresql-client

COPY requirements.txt /
RUN apk add --no-cache --virtual .build-deps gcc libc-dev lzo-dev python3-dev && \
    python3 -m pip install --no-cache-dir -r requirements.txt && \
    apk del .build-deps

COPY src/wale-rest.py .
COPY run.sh /

CMD [ "/run.sh" ]
